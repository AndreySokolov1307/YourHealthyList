//
//  NewTaskViewController.swift
//  YourHealthyList
//
//  Created by Андрей Соколов on 03.01.2024.
//

import Foundation
import UIKit
import HealthKit
import CareKit
import CareKitStore
import HealthKitUI
import Combine

protocol NewTaskViewControllerDelegare: AnyObject {
    func saveNewTask(task: [OCKAnyTask])
}

class NewTaskViewController: UIViewController {
    
    var newItemView: NewItemView? = nil
        
    var event = Event()
    
    weak var delegate: NewTaskViewControllerDelegare?
    
    // Define publisher
    @Published private var taskTitle = ""
    
    private var validToSubmit: AnyPublisher<Bool, Never> {
        return $taskTitle
            .map { name in
                return !name.isEmpty
            }.eraseToAnyPublisher()
    }
    
    // Define subscriber
    private var saveButtonSubscriber: AnyCancellable?
    
    override func loadView() {
        newItemView = NewItemView()
        self.view = newItemView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        cellRegistration()
        setupNavBar()
        
        // Hook subscriber up to publisher
        saveButtonSubscriber = validToSubmit
            .receive(on: RunLoop.main)
            .assign(to: \.!.isEnabled, on: navigationItem.rightBarButtonItem)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeRegistrationForKeyboardNotification()
    }
    
    private func setupView() {
        newItemView?.collectionView.dataSource = self
        newItemView?.collectionView.delegate = self
        newItemView?.collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        newItemView?.collectionView.keyboardDismissMode = .onDrag
    }
    private func setupNavBar() {
        navigationItem.title = "New event"
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Save", style: .plain, target: self,
                            action: #selector(didTapSaveButton))
        navigationItem.rightBarButtonItem?.isEnabled = false
        let backButton = UIButton()
        backButton.setTitle("Back", for: .normal)
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        //default white lol
        backButton.setTitleColor(UIColor { $0.userInterfaceStyle == .light ? #colorLiteral(red: 0.9960784314, green: 0.3725490196, blue: 0.368627451, alpha: 1) : #colorLiteral(red: 0.8627432641, green: 0.2630574384, blue: 0.2592858295, alpha: 1) }, for: .normal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc func didTapBackButton() {
        self.dismiss(animated: true)
    }
    
    @objc func didTapSaveButton() {
        event.endDate.addTimeInterval(TimeInterval(1))
//
//        var nausea = OCKTask(id: "nausea", title: "Track your nausea",
//                             carePlanUUID: nil, schedule: nauseaSchedule)
//        nausea.impactsAdherence = false
//        nausea.instructions = "Tap the button below anytime you experience nausea."
        var dateCompotents = DateComponents()
        
        if let customRepetiton = event.customRepetition {
            switch customRepetiton {
            case .daily:
                dateCompotents = DateComponents(day: event.customRepetitionNumber)
            case .weekly:
                dateCompotents = DateComponents(day: event.customRepetitionNumber * 7)
            case .monthly:
                dateCompotents = DateComponents(month: event.customRepetitionNumber)
            case.yearly:
                dateCompotents = DateComponents(year: event.customRepetitionNumber)
            }
        } else {
            switch event.repetition {
            case .everyDay:
                dateCompotents = DateComponents(day: 1)
            case .everyWeek:
                dateCompotents = DateComponents(day: 7)
            case .everyTwoWeeks:
                dateCompotents = DateComponents(day: 14)
            case .everyMonth:
                dateCompotents = DateComponents(month: 1)
            case .everyYear:
                dateCompotents = DateComponents(year: 1)
            case .custom:
                dateCompotents = DateComponents(day: 1)
            }
        }
        
        switch event.type {
//        case .steps:
//            print("steps")
//            var goal: Double = 1000.0
//            if let name = event.name {
//                goal = Double(name) ?? 1000.0
//            }
//            let schedule = OCKSchedule.dailyAtTime(
//                hour: 8, minutes: 0, start: event.startDate, end: event.endDate, text: "",
//                duration: .hours(15), targetValues: [OCKOutcomeValue( goal, units: "Steps")])

//            var task = OCKTask(id: UUID().uuidString,
//                                        title: "Steps",
//                                        carePlanUUID: nil,
//                                        schedule: schedule,
//                                        healthKitLinkage: OCKHealthKitLinkage(
//                                            quantityIdentifier: .stepCount,
//                                            quantityType: .cumulative,
//                                            unit: .count()))
//            task.groupIdentifier = event.type.rawValue
//            task.instructions = event.note
//            delegate?.saveNewTask(task: [task])
            
            
            
        case .medicineIntake, .custom:
            print("medicine")
            var elements = [OCKScheduleElement]()
            
            var schedule: OCKSchedule? = nil
            
            if event.timesADay == 0 {
                elements.append(OCKScheduleElement(start: event.startDate,
                                                   end: event.endDate,
                                                   interval: dateCompotents))
                
                schedule = OCKSchedule(composing: elements)
            } else {
                for i in 1...event.timesADay {
                    let cell = newItemView?.collectionView.cellForItem(at: IndexPath(item: i, section: 3)) as! DateCell
                    event.timesADayList.append(cell.datePicker.date)
                    elements.append(OCKScheduleElement(start: cell.datePicker.date,
                                                       end: event.endDate,
                                                       interval: dateCompotents))
                }
                schedule = OCKSchedule(composing: elements)
            }
            
            var medTask = OCKTask(id: event.id.uuidString,
                                  title: event.name,
                                  carePlanID: nil,
                                  schedule: schedule!)
            medTask.instructions = event.note
            medTask.asset = "pills"
            medTask.groupIdentifier = event.type.rawValue
            
            delegate?.saveNewTask(task: [medTask])
        case .exersises:
            print("exrsices")
            let thisMorning = Calendar.current.startOfDay(for: Date())
            let beforeBreakfast = Calendar.current.date(byAdding: .hour, value: 8, to: thisMorning)!
            
            let element = OCKScheduleElement(start: beforeBreakfast,
                                             end: event.endDate,
                                             interval: dateCompotents)
            let schedule = OCKSchedule(composing: [element])
            var exersiseTask = OCKTask(id: event.id.uuidString,
                                       title: event.name,
                                       carePlanID: nil,
                                       schedule: schedule)
            exersiseTask.groupIdentifier = event.type.rawValue
            exersiseTask.impactsAdherence = true
            exersiseTask.instructions = event.note
            
            delegate?.saveNewTask(task: [exersiseTask])
        }
        dismiss(animated: true)
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func cellRegistration() {
        newItemView?.collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: "listCell")
        newItemView?.collectionView.register(TextFieldCell.self, forCellWithReuseIdentifier: TextFieldCell.reuseIdentifier)
        newItemView?.collectionView.register(DateCell.self, forCellWithReuseIdentifier: DateCell.reuseIdentifier)
        newItemView?.collectionView.register(TextViewCell.self, forCellWithReuseIdentifier: TextViewCell.reuseIdentifier)
    }
    
    //Make keyboard do not hide textView
    private func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(_:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBiHidden(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func removeRegistrationForKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(_ notification: NSNotification) {
        guard let info = notification.userInfo,
              let keyboardFrameValue = info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardSize = keyboardFrame.size
        
        let contentInsets = UIEdgeInsets(top: 0,
                                         left: 0,
                                         bottom: keyboardSize.height,
                                         right: 0)
        newItemView?.collectionView.contentInset = contentInsets
        newItemView?.collectionView.scrollIndicatorInsets = contentInsets
        let numberOfItemsInSection = newItemView?.collectionView.numberOfItems(inSection: 3)
        let offsetPointHeight = (newItemView?.collectionView.cellForItem(at: IndexPath(item: 0, section: 5))!.frame.height)! + CGFloat(numberOfItemsInSection!) * 44 + 50
        
        let offsetPoint = CGPoint(x: 0, y: offsetPointHeight)
        newItemView?.collectionView.setContentOffset(offsetPoint, animated: true)
        
    }
    
    @objc func keyboardWillBiHidden(_ notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        newItemView?.collectionView.contentInset = contentInsets
        newItemView?.collectionView.scrollIndicatorInsets = contentInsets
    }
    
    //MARK: - UIMenu for TypeCell
    
    private func createUIMenuForTypeCell() -> UIMenu {
        var actions = [UIAction]()
        
        EventType.allCases.forEach { eventType in
            if eventType != .custom {
                let action = UIAction(title: eventType.rawValue) {  action in
                    self.event.type = eventType
                    let cell = self.newItemView?.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! UICollectionViewListCell
                    var content = UIListContentConfiguration.valueCell()
                    content.text = EventType.type
                    content.secondaryText = eventType.rawValue
                    cell.contentConfiguration = content

                    let textFieldCell = self.newItemView?.collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as! TextFieldCell
                    textFieldCell.textField.text = nil
                    var placeholder = ""
                    switch eventType {
                    case .medicineIntake, .exersises:
                        placeholder = "Title"
                        textFieldCell.textField.resignFirstResponder()
                        textFieldCell.textField.keyboardType = .default
//                    case .steps:
//                        placeholder = "Goal"
//                        textFieldCell.textField.resignFirstResponder()
//                        textFieldCell.textField.keyboardType = .decimalPad
                    default:
                        placeholder = "Title"
                    }
                    textFieldCell.textField.placeholder = placeholder
                    
                    self.event.timesADay = 0
                    self.newItemView?.collectionView.reloadSections(IndexSet(integer: 3))
                }
                actions.append(action)
            }
        }
        let customAction = UIAction(title: EventType.custom.rawValue) { action in
            self.event.type = EventType.custom
            let textFieldCell = self.newItemView?.collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as! TextFieldCell
            textFieldCell.textField.text = nil
            textFieldCell.textField.resignFirstResponder()
            textFieldCell.textField.keyboardType = .default
            self.newItemView?.collectionView.reloadItems(at: [IndexPath(item: 0, section: 1)])
            
            let cell = self.newItemView?.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as! UICollectionViewListCell
            var content = UIListContentConfiguration.valueCell()
            content.text = EventType.type
            content.secondaryText = self.event.type.rawValue
            cell.contentConfiguration = content
            
        }
        let customMenu = UIMenu(options: .displayInline, children: [customAction])
        let menu = UIMenu(options: .displayInline, children: actions)
        let mainMenu = UIMenu(title: "", children: [menu, customMenu])
        
        return mainMenu
    }
    
    //MARK: - UIMenu for TimesADayCell
    
    private func createUIMenuForTimesADayCell() -> UIMenu {
        var actions = [UIAction]()
        
        for timesADay in 1...10 {
            let action = UIAction(title: String(timesADay)) {  action in
                self.event.timesADay = timesADay
                self.newItemView?.collectionView.reloadSections(IndexSet(integer: 3))
            }
            actions.append(action)
        }
        
        let allDayAction = UIAction(title: "All day") { action in
            self.event.timesADay = 0
            self.newItemView?.collectionView.reloadSections(IndexSet(integer: 3))
        }
        
        let allDayMenu = UIMenu(options: .displayInline, children: [allDayAction])
        let menu = UIMenu(options: .displayInline, children: actions)
        let mainMenu = UIMenu(title: "", children: [allDayAction, menu])
        
        return mainMenu
    }
    
    //MARK: - UIMenu for Repetititon Cell
    
    private func createUIMenuForRepetition() -> UIMenu {
        var actions = [UIAction]()
        
        Repetition.allCases.forEach { repetition in
            if repetition != .custom {
                let action = UIAction(title: repetition.rawValue) {  action in
                    self.event.repetition = repetition
                    self.event.customRepetition = nil
                    self.newItemView?.collectionView.reloadItems(at: [IndexPath(item: 0, section: 4)])
                }
                actions.append(action)
            }
        }
        let customAction = UIAction(title: Repetition.custom.rawValue) { action in
            self.event.repetition = Repetition.custom
            self.newItemView?.collectionView.reloadItems(at: [IndexPath(item: 0, section: 4)])
            let vc = CustomRepeatViewController(customRepetition: self.event.customRepetition, customNumber: self.event.customRepetitionNumber)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let customMenu = UIMenu(options: .displayInline, children: [customAction])
        let menu = UIMenu(options: .displayInline, children: actions)
        let mainMenu = UIMenu(title: "", children: [menu, customMenu])
        
        return mainMenu
    }
}

//MARK: - UICollectionViewDataSource

extension NewTaskViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
      return 6
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        //Type
        case 0:
           return 1
        //Name (text field)
        case 1:
            return 1
        //Date (start / end)
        case 2:
            return 2
        //Number of times a day
        case 3:
            return event.timesADay + 1
        //Repeating
        case 4:
            if event.customRepetition == nil {
                return 1
            } else {
                return 2
            }
        //Note (textView)
        case 5:
            return 1
        default:
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as! UICollectionViewListCell
            
            var content = UIListContentConfiguration.valueCell()
            content.text = EventType.type
            content.secondaryText = event.type.rawValue
            cell.contentConfiguration = content
            if #available(iOS 16.0, *) {
                cell.accessories = [.popUpMenu(createUIMenuForTypeCell())]
            } else {
                // Fallback on earlier versions
            }
            
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextFieldCell.reuseIdentifier, for: indexPath) as! TextFieldCell
            cell.textField.delegate = self
                cell.textField.placeholder = "Title"
            cell.textField.addTarget(self, action: #selector(textFieldDidChange(sender: )), for: .editingChanged)
            cell.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
            
            return cell
        case 2:
            switch indexPath.item {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateCell.reuseIdentifier, for: indexPath) as! DateCell
                var content = UIListContentConfiguration.valueCell()
                content.text = "Starts"
                cell.contentConfiguration = content
                cell.datePicker.date = event.startDate
                cell.datePicker.addTarget(self, action: #selector(didChangeStartDatePickerValue(sender: )), for: .valueChanged)
                cell.contentView.isUserInteractionEnabled = false
                return cell
            case 1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateCell.reuseIdentifier, for: indexPath) as! DateCell
                var content = UIListContentConfiguration.valueCell()
                content.text = "Ends"
                cell.contentConfiguration = content
                cell.datePicker.date = event.endDate
                cell.datePicker.addTarget(self, action: #selector(didChangeEndDatePickerValue(sender: )), for: .valueChanged)
                cell.contentView.isUserInteractionEnabled = false
                return cell
            default:
                return UICollectionViewCell()
            }
        case 3:
            switch indexPath.item {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as! UICollectionViewListCell
                
                var content = UIListContentConfiguration.valueCell()
                content.text = "Times a day"
                
                if event.type == .exersises {
                    cell.isUserInteractionEnabled = false
                } else {
                    cell.isUserInteractionEnabled = true
                }
                
                if event.timesADay == 0 {
                    content.secondaryText = "All day"
                } else {
                    content.secondaryText = String(event.timesADay)
                }
                cell.contentConfiguration = content
                if #available(iOS 16.0, *) {
                    cell.accessories = [.popUpMenu(createUIMenuForTimesADayCell())]
                } else {
                    // Fallback on earlier versions
                }
                
                
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateCell.reuseIdentifier, for: indexPath) as! DateCell
                var content = UIListContentConfiguration.valueCell()
                content.text = String(indexPath.item)
                cell.contentConfiguration = content
                cell.datePicker.date = Date()
                cell.datePicker.datePickerMode = .time
                cell.contentView.isUserInteractionEnabled = false
                
                return cell
            }
        case 4:
            switch indexPath.item {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as! UICollectionViewListCell
                
                var content = UIListContentConfiguration.valueCell()
                content.text = Repetition.repetition
                content.secondaryText = event.repetition.rawValue
                cell.contentConfiguration = content
                if #available(iOS 16.0, *) {
                    cell.accessories = [.popUpMenu(createUIMenuForRepetition())]
                } else {
                    // Fallback on earlier versions
                }
                
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as! UICollectionViewListCell
                
                var content = UIListContentConfiguration.valueCell()
                if event.customRepetitionNumber > 1 {
                    content.text = "Repeats \(CustomRepetition.everyString.lowercased()) \(event.customRepetitionNumber ) \(event.customRepetition!.plural.lowercased())"
                } else {
                    content.text = "Repeats \(CustomRepetition.everyString.lowercased()) \(event.customRepetition!.rawValue.lowercased())"
                }
        
                content.textProperties.font = UIFont.systemFont(ofSize: 14)
                content.textProperties.color = .systemGray
                cell.contentConfiguration = content
                cell.accessories = [.disclosureIndicator()]
                
                return cell
            }
        case 5:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextViewCell.reuseIdentifier, for: indexPath) as! TextViewCell
            cell.textView.delegate = self
            cell.textView.placeholderLabel.text = "Notes"
            cell.heightAnchor.constraint(greaterThanOrEqualToConstant: 44 * 5).isActive = true
            
            return cell
        default:
         return UICollectionViewCell()
        }
    }
    
    @objc func textFieldDidChange(sender: UITextField) {
        if let text = sender.text {
            taskTitle = text
            event.name = taskTitle
        } else {
            taskTitle = ""
            event.name = taskTitle
        }
    }
    
    @objc func didChangeStartDatePickerValue(sender: UIDatePicker) {
        event.startDate = sender.date
    }
    
    @objc func didChangeEndDatePickerValue(sender: UIDatePicker) {
        event.endDate = sender.date
    }
}

//MARK: - UICollectionViewDelegate

extension NewTaskViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        if indexPath == IndexPath(item: 0, section: 1) || indexPath == IndexPath(item: 0, section: 5) || indexPath == IndexPath(item: 0, section: 2) || indexPath == IndexPath(item: 1, section: 2) {
            return false
        } else  {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if indexPath == IndexPath(item: 1, section: 4) {
            let vc = CustomRepeatViewController(customRepetition: self.event.customRepetition, customNumber: self.event.customRepetitionNumber)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - UITextViewDelegate

extension NewTaskViewController: UITextViewDelegate {
    
    //Making placeholder for textView
    func textViewDidBeginEditing(_ textView: UITextView) {
    
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let myTextView = textView as! TextViewWithPlaceholder
        myTextView.placeholderLabel.isHidden = !myTextView.text.isEmpty
    }
    func textViewDidChange(_ textView: UITextView) {
        let myTextView = textView as! TextViewWithPlaceholder
        
        event.note = myTextView.text
        if myTextView.text.isEmpty {
            myTextView.placeholderLabel.isHidden = false
        } else {
            myTextView.placeholderLabel.isHidden = true
        }
    }
}

//MARK: - UITextFieldDelegate

extension NewTaskViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        event.name = textField.text
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - CustomRepeatViewControllerDelegate

extension NewTaskViewController: CustomRepeatViewControllerDelegate {
    func didSetCustomRepetition(_ repetition: CustomRepetition, customNumber: Int) {
        self.event.customRepetition = repetition
        self.event.customRepetitionNumber = customNumber
        self.newItemView?.collectionView.reloadSections(IndexSet(integer: 4))
    }
}

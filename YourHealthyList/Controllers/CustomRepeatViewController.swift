//
//  CustomRepeatViewController.swift
//  YourHealthyList
//
//  Created by Андрей Соколов on 03.01.2024.
//

import Foundation
import UIKit

protocol CustomRepeatViewControllerDelegate: AnyObject {
    func didSetCustomRepetition(_ repetition: CustomRepetition, customNumber: Int)
}

class CustomRepeatViewController: UIViewController {
 
    var customRepeatView: CustomRepeatView? = nil
    
    var customRepetition: CustomRepetition!
    var customNumber: Int!
  
    init(customRepetition: CustomRepetition!, customNumber: Int!) {
        self.customRepetition = customRepetition
        self.customNumber = customNumber
        if customRepetition == nil {
            self.customRepetition = CustomRepetition.daily
            self.customNumber = 1
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var isPeakerShown = false
    
    weak var delegate: CustomRepeatViewControllerDelegate?
    override func loadView() {
        customRepeatView = CustomRepeatView()
        self.view = customRepeatView
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        cellAndFooterRegistration()
    }
    
    private func setupView() {
        customRepeatView?.collectionView.dataSource = self
        customRepeatView?.collectionView.delegate = self
        customRepeatView?.collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        navigationItem.title = "Custom"
        let backButton = UIButton()
        backButton.setTitle("Back", for: .normal)
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        //default white lol
        backButton.setTitleColor(UIColor { $0.userInterfaceStyle == .light ? #colorLiteral(red: 0.9960784314, green: 0.3725490196, blue: 0.368627451, alpha: 1) : #colorLiteral(red: 0.8627432641, green: 0.2630574384, blue: 0.2592858295, alpha: 1) }, for: .normal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc func didTapBackButton() {
        delegate?.didSetCustomRepetition(customRepetition, customNumber: customNumber)
        navigationController?.popViewController(animated: true)
    }
    
    private func cellAndFooterRegistration() {
        customRepeatView?.collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: "listCell")
        customRepeatView?.collectionView.register(PeakerCell.self, forCellWithReuseIdentifier: PeakerCell.reuseIdentifier)
        
        //Footer
        customRepeatView?.collectionView.register(CollectionViewFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter , withReuseIdentifier: CollectionViewFooter.reuseIdentifier)
    }
    
    private func generateLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.footerMode = .supplementary
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

//MARK: - UICollectionViewDataSource

extension CustomRepeatViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isPeakerShown {
            return 3
        } else {
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.item{
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as! UICollectionViewListCell
                
                var content = UIListContentConfiguration.valueCell()
                content.text = CustomRepetition.frequency
                content.secondaryText = customRepetition.frequency
                cell.contentConfiguration = content
                if #available(iOS 16.0, *) {
                    cell.accessories = [.popUpMenu(createUIMenuForFrequency())]
                } else {
                    // Fallback on earlier versions
                }
                
                return cell
            case 1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as! UICollectionViewListCell
                configureContentForSecondCell(cell: cell, isSelected: false
                )
                
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PeakerCell.reuseIdentifier, for: indexPath) as! PeakerCell
                
                cell.peaker.delegate = self
                cell.peaker.dataSource = self
                cell.peaker.selectRow(customNumber - 1, inComponent: 0, animated: true)
                
                return cell
            }
        default:
            return UICollectionViewListCell()
        }
    }
    
    private func configureContentForSecondCell(cell: UICollectionViewListCell, isSelected: Bool) {
        var content = UIListContentConfiguration.valueCell()
        
        if isSelected {
            content.secondaryTextProperties.color = UIColor { $0.userInterfaceStyle == .light ? #colorLiteral(red: 0.9960784314, green: 0.3725490196, blue: 0.368627451, alpha: 1) : #colorLiteral(red: 0.8627432641, green: 0.2630574384, blue: 0.2592858295, alpha: 1) }
        } else {
            content.secondaryTextProperties.color = .systemGray
        }
        content.text = CustomRepetition.everyString
        if customNumber == 1 {
            content.secondaryText = customRepetition.rawValue
        } else {
            content.secondaryText = "\(customNumber!) \(customRepetition.plural)"
        }
        cell.contentConfiguration = content
    }
    
    //MARK: - UIMenu for Frequency Cell
    
    private func createUIMenuForFrequency() -> UIMenu {
        var actions = [UIAction]()
        
        CustomRepetition.allCases.forEach { frequency in
                let action = UIAction(title: frequency.rawValue) {  action in
                    self.customRepetition = frequency
                    self.customRepeatView?.collectionView.reloadSections(IndexSet(integer: 0))
                }
                actions.append(action)
        }
        let mainMenu = UIMenu(title: "", children: actions)
        
        return mainMenu
    }
}

//MARK: - UICollectionViewDelegate

extension CustomRepeatViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath == IndexPath(item: 1, section: 0) {
            let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewListCell
            isPeakerShown.toggle()

            if isPeakerShown {
                configureContentForSecondCell(cell: cell, isSelected: true)
                collectionView.insertItems(at: [IndexPath(item: 2, section: 0)])
            } else {
                configureContentForSecondCell(cell: cell, isSelected: false)
                collectionView.deleteItems(at: [IndexPath(item: 2, section: 0)])
            }
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CollectionViewFooter.reuseIdentifier, for: indexPath) as! CollectionViewFooter
        
        view.label.text = createFooterLabelText(with: customNumber)
        
        return view
    }
    
    private func createFooterLabelText(with customNumber: Int) -> String {
        var string = "Event will occur every "

        if customNumber > 1 {
            string += "\(customNumber) "
            string += customRepetition.plural
        } else {
            string += customRepetition.rawValue.lowercased()
        }
        
        return string
    }
    
    private func createTextForSecondComponent() -> String {
        if customNumber > 1 {
            return customRepetition.plural
        } else {
            return customRepetition.rawValue.lowercased()
        }
    }
}

//MARK: - UICollectionViewDelegate

extension CustomRepeatViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 99
        } else {
            return 1
        }
    }
}

//MARK: - UICollectionViewDelegate

extension CustomRepeatViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(row + 1)
        } else {
            return createTextForSecondComponent()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadComponent(1)
        
        if component == 0 {
            customNumber = row + 1
            
            let footer = customRepeatView?.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: 0)) as! CollectionViewFooter
            footer.label.text = createFooterLabelText(with: customNumber)
            
            let cell = customRepeatView?.collectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as! UICollectionViewListCell
            configureContentForSecondCell(cell: cell, isSelected: true)
        }
    }
}

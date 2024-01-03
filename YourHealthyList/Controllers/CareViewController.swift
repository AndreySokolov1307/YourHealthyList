//
//  ViewController.swift
//  YourHealthyList
//
//  Created by Андрей Соколов on 27.12.2023.
//

import Foundation
import UIKit
import CareKit
import CareKitStore
import CareKitUI
import SwiftUI




class CareViewController: OCKDailyTasksPageViewController {
    var identifiers: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem =
        UIBarButtonItem(title: "Add new task", style: .plain, target: self,
                        action: #selector(presentNewTaskViewController))
        
        navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBarAppearance()
    }
    
    @objc private func presentNewTaskViewController() {
        let viewController = NewTaskViewController()
        viewController.delegate = self
        
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc private func dismissNewTaskViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    // This will be called each time the selected date changes.
    // Use this as an opportunity to rebuild the content shown to the user.
    override func dailyPageViewController(_ dailyPageViewController: OCKDailyPageViewController,
                                          prepare listViewController: OCKListViewController, for date: Date) {

        var query = OCKTaskQuery(for: date)
        query.excludesTasksWithNoEvents = true

        storeManager.store.fetchAnyTasks(query: query, callbackQueue: .main) { result in
            switch result {
            case .failure(let error): print("Error: \(error)")
            case .success(let tasks):

                // Add a non-CareKit view into the list
                let tipTitle = "Benefits of doping"
                let tipText = "Learn how doping can promote a maybe healthy pregnancy."

                // Only show the tip view on the current date
                if Calendar.current.isDate(date, inSameDayAs: Date()) {
                    let tipView = TipView()
                    tipView.headerView.titleLabel.text = tipTitle
                    tipView.headerView.detailLabel.text = tipText
                    tipView.imageView.image = UIImage(systemName: "pills")
                    listViewController.appendView(tipView, animated: false)
                }

                let exersiseTasks = tasks.filter { $0.groupIdentifier == EventType.exersises.rawValue}


                exersiseTasks.forEach { task in
                    let exersiseCard = OCKSimpleTaskViewController(task: task, eventQuery: .init(for: date),
                                                                   storeManager: self.storeManager)
                    listViewController.appendViewController(exersiseCard, animated: false)
                }

//                let stepTasks = tasks.filter { $0.groupIdentifier == EventType.steps.rawValue}

//                stepTasks.forEach { task in
//                    let view = NumericProgressTaskView(
//                        task: task,
//                        eventQuery: OCKEventQuery(for: date),
//                        storeManager: self.storeManager)
//                        .padding([.vertical], 20)
//
//                    listViewController.appendViewController(view.formattedHostingController(), animated: false)
//                }


                let medTasks = tasks.filter { $0.groupIdentifier == EventType.medicineIntake.rawValue || $0.groupIdentifier == EventType.custom.rawValue}

                medTasks.forEach { task in
                    var medCard = OCKChecklistTaskViewController(
                        task: task,
                        eventQuery: .init(for: date),
                        storeManager: self.storeManager)

                    listViewController.appendViewController(medCard, animated: false)
                }
                }
            }
        }
 }

private extension View {
    func formattedHostingController() -> UIHostingController<Self> {
        let viewController = UIHostingController(rootView: self)
        viewController.view.backgroundColor = .clear
        return viewController
    }
}

extension CareViewController: NewTaskViewControllerDelegare {
    func saveNewTask(task: [OCKAnyTask]) {
        storeManager.store.addAnyTasks(task, callbackQueue: .main) {_ in
            
        }
    }
}

    

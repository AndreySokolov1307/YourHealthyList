//
//  DateCell.swift
//  YourHealthyList
//
//  Created by Андрей Соколов on 03.01.2024.
//

import Foundation
import UIKit

class DateCell: UICollectionViewListCell {
    static let reuseIdentifier = "DateCell"
    
    let datePicker: UIDatePicker = {
       let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCell() {
        addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            datePicker.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }
}

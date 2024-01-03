//
//  TextFieldCell.swift
//  YourHealthyList
//
//  Created by Андрей Соколов on 03.01.2024.
//

import Foundation
import UIKit

@available(iOS 14.0, *)
class TextFieldCell: UICollectionViewListCell {
    static let reuseIdentifier = "TextFieldCell"
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCell() {
        addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }
}

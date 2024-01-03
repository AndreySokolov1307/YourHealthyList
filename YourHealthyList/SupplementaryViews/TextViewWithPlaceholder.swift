//
//  TextViewWithPlaceholder.swift
//  YourHealthyList
//
//  Created by Андрей Соколов on 03.01.2024.
//

import Foundation
import UIKit

class TextViewWithPlaceholder: UITextView {
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .placeholderText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
        ])
    }
}

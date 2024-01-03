//
//  PeakerCell.swift
//  YourHealthyList
//
//  Created by Андрей Соколов on 03.01.2024.
//

import Foundation
import UIKit

class PeakerCell: UICollectionViewListCell{
    static let reuseIdentifier = "Peaker"
    
    let peaker: UIPickerView = {
       let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
  
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCell() {
        addSubview(peaker)
        
        NSLayoutConstraint.activate([
            peaker.leadingAnchor.constraint(equalTo: leadingAnchor),
            peaker.trailingAnchor.constraint(equalTo: trailingAnchor),
            peaker.topAnchor.constraint(equalTo: topAnchor),
            peaker.bottomAnchor.constraint(equalTo: bottomAnchor),
           
        ])
        // чтобы не ругалась залупа в консоли про констреинты
        //UPD anyway rugaetsya no po drugomu, koroche norm
        let z = peaker.heightAnchor.constraint(equalToConstant: 216)
        z.isActive = true
        z.priority = UILayoutPriority(998)
    }
}

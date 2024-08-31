//
//  RoundedBackTextField.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/23/24.
//

import UIKit

final class RoundedBackTextField: UITextField {
    
    init(placeholder: String) {
        super.init(frame: .zero)
        configure(placeholder: placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(placeholder: String) {
        self.font = .systemFont(ofSize: 14)
        self.placeholder = placeholder
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        self.layer.borderColor = UIColor.black.cgColor
        self.backgroundColor = .systemGray6
        self.layer.cornerRadius = 15
        self.clearButtonMode = .whileEditing
        self.leftViewMode = .always
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
    }
}

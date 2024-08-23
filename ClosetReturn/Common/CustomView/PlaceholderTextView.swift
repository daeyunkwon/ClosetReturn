//
//  PlaceholderTextView.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/23/24.
//

import UIKit

import SnapKit

final class PlaceholderTextView: UITextView {
    
    private let placeholder: String
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.font = Constant.Font.bodyFont
        return label
    }()
    
    init(placeholder: String) {
        self.placeholder = placeholder
        super.init(frame: .zero, textContainer: .none)
        self.configure(placeholder: placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(placeholder: String) {
        placeholderLabel.text = placeholder
        
        addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        self.backgroundColor = .systemGray6
        self.layer.cornerRadius = 15
        self.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.font = Constant.Font.bodyFont
    }
}


//
//  InputTextFieldView.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/16/24.
//

import UIKit

import SnapKit

final class InputTextFieldView: UIView {
    
    //MARK: - Properties
    
    enum TextFieldType {
        case loginPassword
        case logionNotPassword
        case signUpPassword
        case signUpNotPassword
    }
    
    private var type: TextFieldType
    
    //MARK: - Init
    
    init(viewType: TextFieldType, title: String, placeholder: String) {
        
        self.type = viewType
        super.init(frame: .zero)
        
        titleLabel.text = title
        inputTextField.placeholder = placeholder
        
        switch viewType {
        case .loginPassword, .signUpPassword:
            hideButton.isHidden = false
            inputTextField.isSecureTextEntry = true
        case .logionNotPassword, .signUpNotPassword:
            hideButton.isHidden = true
            inputTextField.isSecureTextEntry = false
        }
        
        configureHierarchy()
        configureLayout()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.secondaryTitleFont
        label.textColor = Constant.Color.Text.secondaryColor
        label.textAlignment = .left
        return label
    }()
    
    let inputTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = Constant.Color.Text.bodyColor
        tf.font = Constant.Font.bodyFont
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .none
        return tf
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.infoFont
        label.alpha = 0.7
        label.textColor = .systemGreen
        return label
    }()
    
    let hideButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "eye"), for: .normal)
        btn.tintColor = Constant.Color.Icon.primaryColor
        return btn
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        return view
    }()
    
    //MARK: - Configurations
    
    private func configureHierarchy() {
        self.addSubviews(
            titleLabel,
            hideButton,
            inputTextField,
            separatorView,
            descriptionLabel
        )
    }
    
    private func configureLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(self.safeAreaLayoutGuide)
        }
        
        hideButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(9)
            make.height.equalTo(20)
            make.width.equalTo(27)
            make.trailing.equalTo(self.safeAreaLayoutGuide).inset(10)
        }
        
        inputTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.leading.equalTo(self.safeAreaLayoutGuide)
            
            switch type {
            case .loginPassword, .signUpPassword:
                make.trailing.equalTo(hideButton.snp.leading).offset(-2)
            case .logionNotPassword, .signUpNotPassword:
                make.trailing.equalTo(self.safeAreaLayoutGuide)
            }
            
            make.height.equalTo(30)
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(inputTextField.snp.bottom)
            make.horizontalEdges.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(0.6)
            make.bottom.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(3)
            make.horizontalEdges.equalTo(self.safeAreaLayoutGuide)
        }
    }
    
    private func configureUI() {
        self.backgroundColor = Constant.Color.View.viewBackgroundColor
    }
}

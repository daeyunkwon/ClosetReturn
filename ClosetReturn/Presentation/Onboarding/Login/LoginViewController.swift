//
//  LoginViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/16/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class LoginViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    private let viewModel = LoginViewModel()
    
    //MARK: - UI Components
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "옷장리턴"
        label.font = Constant.Font.brandFont
        label.textColor = Constant.Color.Text.titleColor
        return label
    }()
    
    private let emailInputView = InputTextFieldView(viewType: .logionNotPassword, title: "이메일", placeholder: "이메일")
    private let passwordInputView = InputTextFieldView(viewType: .loginPassword, title: "비밀번호", placeholder: "비밀번호")
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그인", for: .normal)
        button.titleLabel?.font = Constant.Font.buttonTitleFont
        button.backgroundColor = Constant.Color.brandColor
        button.tintColor = Constant.Color.Button.titleColor
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let signUpButton: UIButton = {
        let btn = UIButton(type: .system)

        let attributedString = NSMutableAttributedString(string: "계정이 없으신가요? ", attributes: [.foregroundColor: Constant.Color.Text.secondaryColor, .font: Constant.Font.secondaryFont])
        attributedString.append(NSAttributedString(string: "가입하기", attributes: [.foregroundColor: Constant.Color.brandColor, .font: Constant.Font.bodyBoldFont]))
        btn.setAttributedTitle(attributedString, for: .normal)
        return btn
    }()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func bind() {
        
        let input = LoginViewModel.Input(email: emailInputView.inputTextField.rx.text.orEmpty, password: passwordInputView.inputTextField.rx.text.orEmpty, loginButtonTapped: loginButton.rx.tap, signButtonTapped: signUpButton.rx.tap, hideButtonTapped: passwordInputView.hideButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        output.hideButtonTapped
            .bind(with: self) { owner, _ in
                owner.passwordInputView.inputTextField.isSecureTextEntry.toggle()
                
                if owner.passwordInputView.inputTextField.isSecureTextEntry {
                    owner.passwordInputView.hideButton.setImage(UIImage(systemName: "eye"), for: .normal)
                } else {
                    owner.passwordInputView.hideButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
                }
            }
            .disposed(by: disposeBag)
        
        output.succeedToLogin
            .bind(with: self) { owner, value in
                print("로그인 성공!: \(value)")
                owner.setRootViewController(ViewController())
            }
            .disposed(by: disposeBag)
           
        output.failedToLogin
            .bind(with: self) { owner, error in
                owner.showNetworkRequestFailAlert(errorType: error)
            }
            .disposed(by: disposeBag)
        
        output.signButtonTapped
            .bind(with: self) { owner, _ in
                owner.pushViewController(SignUpViewController())
                owner.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    override func setupNavi() {
        navigationItem.title = "" 
    }
    
    override func configureHierarchy() {
        view.addSubviews(
            logoLabel,
            emailInputView,
            passwordInputView,
            loginButton,
            signUpButton
        )
    }
    
    override func configureLayout() {
        logoLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.centerX.equalToSuperview()
        }
        
        emailInputView.snp.makeConstraints { make in
            make.top.equalTo(logoLabel.snp.bottom).offset(50)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        passwordInputView.snp.makeConstraints { make in
            make.top.equalTo(emailInputView.snp.bottom).offset(47)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordInputView.snp.bottom).offset(50)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(45)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
}

//
//  SignUpViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/16/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class SignUpViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let viewModel = SignUpViewModel()
    
    //MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.Text.titleColor
        label.font = .systemFont(ofSize: 30, weight: .heavy)
        label.text = "회원가입"
        return label
    }()
    
    private let scrollView = UIScrollView()
    
    private let containerView = UIView()
    
    private let birthdayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko-KR")
        picker.maximumDate = Date()
        return picker
    }()
    
    private let emailInputView = InputTextFieldView(viewType: .notPassword, title: "이메일", placeholder: "예시) welcome@email.com", showAsterisk: true)
    private let passwordInputView = InputTextFieldView(viewType: .password, title: "비밀번호", placeholder: "비밀번호를 입력해 주세요", showAsterisk: true)
    private let recheckPasswordInputView = InputTextFieldView(viewType: .password, title: "비밀번호 확인", placeholder: "비밀번호 재입력", showAsterisk: true)
    private let nicknameInputView = InputTextFieldView(viewType: .notPassword, title: "닉네임", placeholder: "다른 유저들에게 보여질 닉네임을 입력해 주세요", showAsterisk: true)
    private let phoneNumberInputView = {
        let view = InputTextFieldView(viewType: .notPassword, title: "휴대전화 (선택)", placeholder: "(-)없이 숫자만 입력해 주세요")
        view.inputTextField.keyboardType = .numberPad
        return view
    }()
    private lazy var birthdayInputView = {
        let view = InputTextFieldView(viewType: .notPassword, title: "생년월일 (선택)", placeholder: "생년월일")
        view.inputTextField.inputView = birthdayPicker
        return view
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("가입하기", for: .normal)
        button.titleLabel?.font = Constant.Font.buttonTitleFont
        button.tintColor = Constant.Color.Button.titleColor
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = .init(width: 0, height: 1)
        button.isUserInteractionEnabled = false
        button.backgroundColor = Constant.Color.Button.buttonDisabled
        return button
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)

        let attributedString = NSMutableAttributedString(string: "이미 계정이 있으신가요? ", attributes: [.foregroundColor: Constant.Color.Text.secondaryColor, .font: Constant.Font.secondaryFont])
        attributedString.append(NSAttributedString(string: "로그인", attributes: [.foregroundColor: Constant.Color.brandColor, .font: Constant.Font.bodyBoldFont]))
        btn.setAttributedTitle(attributedString, for: .normal)
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
    private let checkEmailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("중복확인", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 13)
        button.backgroundColor = Constant.Color.Button.titleColor
        button.tintColor = Constant.Color.brandColor
        button.layer.borderColor = Constant.Color.brandColor.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = .init(width: 0, height: 1)
        button.isUserInteractionEnabled = true
        button.isEnabled = false
        return button
    }()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func bind() {
        let input = SignUpViewModel.Input(
            loginButtonTap: loginButton.rx.tap,
            email: emailInputView.inputTextField.rx.text.orEmpty,
            checkEmailButtonTap: checkEmailButton.rx.tap,
            password: passwordInputView.inputTextField.rx.text.orEmpty,
            passwordHideButtonTap: passwordInputView.hideButton.rx.tap,
            recheckPassword: recheckPasswordInputView.inputTextField.rx.text.orEmpty,
            recheckPasswordHideButtonTap: recheckPasswordInputView.hideButton.rx.tap,
            nickname: nicknameInputView.inputTextField.rx.text.orEmpty,
            phoneNumber: phoneNumberInputView.inputTextField.rx.text.orEmpty,
            birthday: birthdayPicker.rx.date,
            signUpButtonTap: signUpButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        
        Observable.zip(output.emailValid, output.emailValidInfo, output.emailCheckValid)
            .bind(onNext: { [weak self] value in
                guard let self else { return }
                self.emailInputView.descriptionLabel.text = value.1
                
                if value.0 {
                    if value.2 {
                        self.emailInputView.descriptionLabel.textColor = .systemGreen
                    } else {
                        self.emailInputView.descriptionLabel.textColor = Constant.Color.Text.secondaryColor
                    }
                    self.checkEmailButton.isEnabled = true
                } else {
                    self.emailInputView.descriptionLabel.textColor = .systemRed
                    self.checkEmailButton.isEnabled = false
                }
            })
            .disposed(by: disposeBag)
        
        Observable.zip(output.passwordValid, output.passwordValidInfo)
            .bind(onNext: { [weak self] value in
                guard let self else { return }
                self.passwordInputView.descriptionLabel.text = value.1
                
                if value.0 {
                    self.passwordInputView.descriptionLabel.textColor = .systemGreen
                } else {
                    self.passwordInputView.descriptionLabel.textColor = .systemRed
                }
            })
            .disposed(by: disposeBag)
        
        Observable.zip(output.recheckPasswordValid, output.recheckPasswordValidInfo)
            .bind(onNext: { [weak self] value in
                guard let self else { return }
                self.recheckPasswordInputView.descriptionLabel.text = value.1
                
                if value.0 {
                    self.recheckPasswordInputView.descriptionLabel.textColor = .systemGreen
                } else {
                    self.recheckPasswordInputView.descriptionLabel.textColor = .systemRed
                }
            })
            .disposed(by: disposeBag)
        
        Observable.zip(output.nicknameValid, output.nicknameValidInfo)
            .bind(onNext: { [weak self] value in
                guard let self else { return }
                self.nicknameInputView.descriptionLabel.text = value.1
                
                if value.0 {
                    self.nicknameInputView.descriptionLabel.textColor = .systemGreen
                } else {
                    self.nicknameInputView.descriptionLabel.textColor = .systemRed
                }
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(output.phoneNumberValid, output.phoneNumberValidInfo)
            .bind(onNext: { [weak self] value in
                guard let self else { return }
                self.phoneNumberInputView.descriptionLabel.text = value.1
                
                if value.0 {
                    self.phoneNumberInputView.descriptionLabel.textColor = .systemGreen
                } else {
                    self.phoneNumberInputView.descriptionLabel.textColor = .systemRed
                }
            })
            .disposed(by: disposeBag)
        
        output.birthdayString
            .bind(to: birthdayInputView.inputTextField.rx.text)
            .disposed(by: disposeBag)
        
        output.failedToEmailValidationRequest
            .bind(with: self) { owner, error in
                owner.showNetworkRequestFailAlert(errorType: error)
            }
            .disposed(by: disposeBag)
        
        output.loginButtonTap
            .bind(with: self) { owner, _ in
                owner.popViewController()
            }
            .disposed(by: disposeBag)
        
        output.passwordHideButtonTap
            .bind(with: self) { owner, _ in
                owner.passwordInputView.inputTextField.isSecureTextEntry.toggle()
                
                if owner.passwordInputView.inputTextField.isSecureTextEntry {
                    owner.passwordInputView.hideButton.setImage(UIImage(systemName: "eye"), for: .normal)
                } else {
                    owner.passwordInputView.hideButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
                }
            }
            .disposed(by: disposeBag)
        
        output.recheckPasswordHideButtonTap
            .bind(with: self) { owner, _ in
                owner.recheckPasswordInputView.inputTextField.isSecureTextEntry.toggle()
                
                if owner.recheckPasswordInputView.inputTextField.isSecureTextEntry {
                    owner.recheckPasswordInputView.hideButton.setImage(UIImage(systemName: "eye"), for: .normal)
                } else {
                    owner.recheckPasswordInputView.hideButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
                }
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(output.emailCheckValid, output.passwordValid, output.recheckPasswordValid, output.nicknameValid, output.phoneNumberValid)
            .map { $0.0 == $0.1 && $0.1 == $0.2 && $0.2 == $0.3 && $0.3 == $0.4 && $0.0 == true && $0.1 == true && $0.2 == true && $0.3 == true && $0.4 == true }
            .bind(with: self) { owner, value in
                owner.signUpButton.isUserInteractionEnabled = value
                if value {
                    owner.signUpButton.backgroundColor = Constant.Color.brandColor
                } else {
                    owner.signUpButton.backgroundColor = Constant.Color.Button.buttonDisabled
                }
            }
            .disposed(by: disposeBag)
        
        output.signUpDone
            .bind(with: self) { owner, result in
                switch result {
                case .success(_):
                    let vc = SignUpCompleteViewController()
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    owner.present(vc, animated: true)
                
                case .failure(let networkError):
                    owner.showNetworkRequestFailAlert(errorType: networkError)
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    override func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubviews(
            titleLabel,
            loginButton,
            emailInputView,
            passwordInputView,
            recheckPasswordInputView,
            nicknameInputView,
            phoneNumberInputView,
            birthdayInputView,
            signUpButton,
            checkEmailButton
        )
    }
    
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.width.equalTo(view.frame.size.width)
            make.verticalEdges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        emailInputView.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(50)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        checkEmailButton.snp.makeConstraints { make in
            make.top.equalTo(emailInputView.snp.bottom).offset(5)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(60)
            make.height.equalTo(22)
        }
        
        passwordInputView.snp.makeConstraints { make in
            make.top.equalTo(emailInputView.snp.bottom).offset(50)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        recheckPasswordInputView.snp.makeConstraints { make in
            make.top.equalTo(passwordInputView.snp.bottom).offset(50)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        nicknameInputView.snp.makeConstraints { make in
            make.top.equalTo(recheckPasswordInputView.snp.bottom).offset(50)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        phoneNumberInputView.snp.makeConstraints { make in
            make.top.equalTo(nicknameInputView.snp.bottom).offset(50)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        birthdayInputView.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberInputView.snp.bottom).offset(50)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(birthdayInputView.snp.bottom).offset(50)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(45)
            make.bottom.equalToSuperview().inset(220)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
}

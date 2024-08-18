//
//  SignUpViewModel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/16/24.
//

import Foundation

import RxSwift
import RxCocoa

final class SignUpViewModel: BaseViewModel {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    private var emailValue: String = ""
    private var passwordValue: String = ""
    private var nicknameValue: String = ""
    private var phoneNumberValue: String = ""
    private var birthdayValue: String = ""
    
    //MARK: - Inputs
    
    struct Input {
        let loginButtonTap: ControlEvent<Void>
        let email: ControlProperty<String>
        let checkEmailButtonTap: ControlEvent<Void>
        let password: ControlProperty<String>
        let passwordHideButtonTap: ControlEvent<Void>
        let recheckPassword: ControlProperty<String>
        let recheckPasswordHideButtonTap: ControlEvent<Void>
        let nickname: ControlProperty<String>
        let phoneNumber: ControlProperty<String>
        let birthday: ControlProperty<Date>
        let signUpButtonTap: ControlEvent<Void>
    }
    
    //MARK: - Outputs
    
    struct Output {
        let loginButtonTap: ControlEvent<Void>
        let emailValidInfo: PublishRelay<String>
        let emailValid: PublishRelay<Bool>
        let emailCheckValid: PublishRelay<Bool>
        let failedToEmailValidationRequest: PublishSubject<NetworkError>
        let passwordValidInfo: PublishRelay<String>
        let passwordValid: PublishRelay<Bool>
        let passwordHideButtonTap: ControlEvent<Void>
        let recheckPasswordValidInfo: PublishRelay<String>
        let recheckPasswordValid: PublishRelay<Bool>
        let recheckPasswordHideButtonTap: ControlEvent<Void>
        let nicknameValidInfo: PublishRelay<String>
        let nicknameValid: PublishRelay<Bool>
        let phoneNumberValidInfo: PublishRelay<String>
        let phoneNumberValid: BehaviorRelay<Bool>
        let birthdayString: PublishRelay<String>
    }
    
    //MARK: - Methods
    
    func transform(input: Input) -> Output {
        
        let emailValidInfo = PublishRelay<String>()
        let emailValid = PublishRelay<Bool>()
        let emailCheckValid = PublishRelay<Bool>()
        let failedToEmailValidationRequest = PublishSubject<NetworkError>()
        let passwordValidInfo = PublishRelay<String>()
        let passwordValid = PublishRelay<Bool>()
        let recheckPasswordValidInfo = PublishRelay<String>()
        let recheckPasswordValid = PublishRelay<Bool>()
        let nicknameValidInfo = PublishRelay<String>()
        let nicknameValid = PublishRelay<Bool>()
        let phoneNumberValidInfo = PublishRelay<String>()
        let phoneNumberValid = BehaviorRelay<Bool>(value: true)
        let birthdayString = PublishRelay<String>()
        
        
        input.email
            .distinctUntilChanged()
            .bind(with: self) { owner, value in
                emailCheckValid.accept(false)
                if owner.isValidEmail(email: value) {
                    emailValid.accept(true)
                    emailValidInfo.accept("이메일 중복 확인을 해주세요.")
                } else {
                    emailValid.accept(false)
                    emailValidInfo.accept("이메일 형식이 올바르지 않습니다.")
                }
            }
            .disposed(by: disposeBag)
        
        input.checkEmailButtonTap
            .withLatestFrom(input.email)
            .filter { !$0.isEmpty }
            .bind(with: self, onNext: { owner, email in
                NetworkManager.shared.performRequest(api: .emailValidation(email: email))
                    .subscribe(with: self) { owner, result in
                        switch result {
                        case .success(_):
                            emailValid.accept(true)
                            emailValidInfo.accept("사용 가능한 이메일입니다.")
                            emailCheckValid.accept(true)
                            owner.emailValue = email
                        
                        case .failure(let error):
                            if error == NetworkError.statusError(codeNumber: 409) {
                                emailValidInfo.accept("사용이 불가한 이메일입니다.")
                            } else {
                                failedToEmailValidationRequest.onNext(error)
                            }
                            emailValid.accept(false)
                            emailCheckValid.accept(false)
                        }
                    }
                    .disposed(by: owner.disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.password
            .bind(with: self) { owner, value in
                owner.passwordValue = value
                
                if owner.isValidPassword(password: value) {
                    passwordValid.accept(true)
                    passwordValidInfo.accept("사용이 가능한 비밀번호입니다.")
                } else {
                    passwordValid.accept(false)
                    passwordValidInfo.accept("영문, 숫자, 특수문자를 최소 1개씩 조합해서 8자 이상 20자 이하로 입력해주세요.")
                }
                
                input.recheckPassword
                    .bind(with: self) { owner, value in
                        if value == owner.passwordValue {
                            if !value.isEmpty {
                                recheckPasswordValid.accept(true)
                                recheckPasswordValidInfo.accept("비밀번호가 일치합니다.")
                            }
                        } else {
                                recheckPasswordValid.accept(false)
                            if !value.isEmpty {
                                recheckPasswordValidInfo.accept("비밀번호가 일치하지 않습니다.")
                            } else {
                                recheckPasswordValidInfo.accept("")
                            }
                        }
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        input.nickname
            .bind(with: self) { owner, value in
                owner.nicknameValue = value
                if owner.isValidNickname(nickname: value) {
                    nicknameValid.accept(true)
                    nicknameValidInfo.accept("사용 가능한 닉네임입니다.")
                } else {
                    nicknameValid.accept(false)
                    nicknameValidInfo.accept("특수 기호와 공백을 제외한 15자 이내로만 입력해 주세요.")
                }
            }
            .disposed(by: disposeBag)
        
        input.phoneNumber
            .bind(with: self) { owner, value in
                owner.phoneNumberValue = value
                if owner.isValidPhoneNumber(phoneNumber: value) {
                    phoneNumberValid.accept(true)
                    phoneNumberValidInfo.accept("")
                } else {
                    if value.isEmpty {
                        phoneNumberValid.accept(true)
                        phoneNumberValidInfo.accept("")
                    } else {
                        phoneNumberValid.accept(false)
                        phoneNumberValidInfo.accept("11자리의 숫자만 입력해 주세요")
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.birthday
            .skip(1)
            .bind(with: self) { owner, value in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd"
                owner.birthdayValue = dateFormatter.string(from: value)
                
                dateFormatter.dateFormat = "yyyy년 M월 d일"
                let string = dateFormatter.string(from: value)
                birthdayString.accept(string)
            }
            .disposed(by: disposeBag)
        
        
        
        
        input.signUpButtonTap
            .bind(with: self) { owner, _ in
                print(owner.emailValue)
                print(owner.passwordValue)
                print(owner.nicknameValue)
                print(owner.phoneNumberValue)
                print(owner.birthdayValue)
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            loginButtonTap: input.loginButtonTap,
            emailValidInfo: emailValidInfo,
            emailValid: emailValid,
            emailCheckValid: emailCheckValid,
            failedToEmailValidationRequest: failedToEmailValidationRequest,
            passwordValidInfo: passwordValidInfo,
            passwordValid: passwordValid,
            passwordHideButtonTap: input.passwordHideButtonTap,
            recheckPasswordValidInfo: recheckPasswordValidInfo,
            recheckPasswordValid: recheckPasswordValid,
            recheckPasswordHideButtonTap: input.recheckPasswordHideButtonTap,
            nicknameValidInfo: nicknameValidInfo,
            nicknameValid: nicknameValid,
            phoneNumberValidInfo: phoneNumberValidInfo,
            phoneNumberValid: phoneNumberValid,
            birthdayString: birthdayString
        )
    }
    
    private func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    private func isValidPassword(password: String) -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[0-9])(?=.*[!_@$%^&+=-])[A-Z0-9a-z.!_@$%^&+=-]{8,20}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
    }
    
    private func isValidNickname(nickname: String) -> Bool {
        let nicknameRegEx = "^[a-zA-Z0-9가-힣_-]{1,15}$"
        let nicknameTest = NSPredicate(format: "SELF MATCHES %@", nicknameRegEx)
        return nicknameTest.evaluate(with: nickname)
    }
    
    private func isValidPhoneNumber(phoneNumber: String) -> Bool {
        let phoneNumberRegEx = "^[0-9]{3,3}+[0-9]{4,4}+[0-9]{4,4}$"
        let phoneNumberTest = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegEx)
        return phoneNumberTest.evaluate(with: phoneNumber)
    }
}

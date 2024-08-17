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
    
    //MARK: - Inputs
    
    struct Input {
        let loginButtonTap: ControlEvent<Void>
        let email: ControlProperty<String>
        let checkEmailButtonTap: ControlEvent<Void>
        let password: ControlProperty<String>
        let passwordHideButtonTap: ControlEvent<Void>
    }
    
    //MARK: - Outputs
    
    struct Output {
        let loginButtonTap: ControlEvent<Void>
        let emailValidInfo: PublishRelay<String>
        let emailValid: PublishRelay<Bool>
        let failedToEmailValidationRequest: PublishSubject<NetworkError>
        let passwordValidInfo: PublishRelay<String>
        let passwordValid: PublishRelay<Bool>
        let passwordHideButtonTap: ControlEvent<Void>
    }
    
    //MARK: - Methods
    
    func transform(input: Input) -> Output {
        
        let emailValidInfo = PublishRelay<String>()
        let emailValid = PublishRelay<Bool>()
        let failedToEmailValidationRequest = PublishSubject<NetworkError>()
        let passwordValidInfo = PublishRelay<String>()
        let passwordValid = PublishRelay<Bool>()
        
        
        input.email
            .bind(with: self) { owner, value in
                if owner.isValidEmail(email: value) {
                    emailValid.accept(true)
                    emailValidInfo.accept("")
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
                        
                        case .failure(let error):
                            if error == NetworkError.statusError(codeNumber: 409) {
                                emailValid.accept(false)
                                emailValidInfo.accept("사용이 불가한 이메일입니다.")
                            } else {
                                failedToEmailValidationRequest.onNext(error)
                            }
                        }
                    }
                    .disposed(by: owner.disposeBag)
            })
            .disposed(by: disposeBag)
        
        input.password
            .bind(with: self) { owner, value in
                if owner.isValidPassword(password: value) {
                    passwordValid.accept(true)
                    passwordValidInfo.accept("사용이 가능한 비밀번호입니다.")
                } else {
                    passwordValid.accept(false)
                    passwordValidInfo.accept("영문, 숫자, 특수문자를 최소 1개씩 조합해서 8자 이상 20자 이하로 입력해주세요.")
                }
            }
            .disposed(by: disposeBag)
        
        
        
        
        return Output(
            loginButtonTap: input.loginButtonTap,
            emailValidInfo: emailValidInfo,
            emailValid: emailValid,
            failedToEmailValidationRequest: failedToEmailValidationRequest,
            passwordValidInfo: passwordValidInfo,
            passwordValid: passwordValid,
            passwordHideButtonTap: input.passwordHideButtonTap
        )
    }
    
    private func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{3,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    private func isValidPassword(password: String) -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[0-9])(?=.*[!_@$%^&+=-])[A-Z0-9a-z.!_@$%^&+=-]{8,20}"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
    }
}

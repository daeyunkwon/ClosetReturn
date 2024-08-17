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
    }
    
    //MARK: - Outputs
    
    struct Output {
        let loginButtonTap: ControlEvent<Void>
        let emailValidInfo: PublishRelay<String>
        let emailValid: PublishRelay<Bool>
        let failedToEmailValidationRequest: PublishSubject<NetworkError>
    }
    
    //MARK: - Methods
    
    func transform(input: Input) -> Output {
        
        let emailValidInfo = PublishRelay<String>()
        let emailValid = PublishRelay<Bool>()
        let failedToEmailValidationRequest = PublishSubject<NetworkError>()
        
        
        input.email
            .filter { !$0.isEmpty }
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
        
        
        
        
        return Output(loginButtonTap: input.loginButtonTap, emailValidInfo: emailValidInfo, emailValid: emailValid, failedToEmailValidationRequest: failedToEmailValidationRequest)
    }
    
    private func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{3,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}

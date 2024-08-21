//
//  LoginViewModel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/16/24.
//

import Foundation

import RxSwift
import RxCocoa

final class LoginViewModel: BaseViewModel {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    private var emailValue = ""
    private var passwordValue = ""
    
    //MARK: - Inputs
    
    struct Input {
        let email: ControlProperty<String>
        let password: ControlProperty<String>
        let loginButtonTapped: ControlEvent<Void>
        let signButtonTapped: ControlEvent<Void>
        let hideButtonTapped: ControlEvent<Void>
    }
    
    //MARK: - Outputs
    
    struct Output {
        let succeedToLogin: PublishSubject<Login>
        let failedToLogin: PublishSubject<(NetworkError, RouterType)>
        let signButtonTapped: ControlEvent<Void>
        let hideButtonTapped: ControlEvent<Void>
    }
    
    //MARK: - Methods
    
    func transform(input: Input) -> Output {
        let succeedToLogin = PublishSubject<Login>()
        let failedToLogin = PublishSubject<(NetworkError, RouterType)>()
        
        input.email
            .bind(with: self) { owner, value in
                owner.emailValue = value
            }
            .disposed(by: disposeBag)
        
        input.password
            .bind(with: self) { owner, value in
                owner.passwordValue = value
            }
            .disposed(by: disposeBag)
        
        input.loginButtonTapped
            .bind(with: self) { owner, _ in
                NetworkManager.shared.performRequest(api: .loginUser(email: owner.emailValue, password: owner.passwordValue), model: Login.self)
                    .subscribe(with: self) { owner, result in
                        switch result {
                        case .success(let value):
                            succeedToLogin.onNext(value)
                            
                            UserDefaultsManager.shared.refreshToken = value.refreshToken
                            
                            let access = value.accessToken
                            let userID = value.user_id
                            UserDefaultsManager.shared.accessToken = access
                            UserDefaultsManager.shared.userID = userID
                            
                            print(value.accessToken)
                            print(UserDefaultsManager.shared.accessToken)
                            print("======================================")
                            
                            //버그때문에 한 번 더 저장
                            let refresh = value.refreshToken
                            UserDefaultsManager.shared.refreshToken = refresh
                            
                            print(value.refreshToken)
                            print(UserDefaultsManager.shared.refreshToken)
                            
                            
                            
                        case .failure(let error):
                            failedToLogin.onNext((error, RouterType.loginUser))
                            UserDefaultsManager.shared.removeAll()
                        }
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        
        return Output(succeedToLogin: succeedToLogin, failedToLogin: failedToLogin, signButtonTapped: input.signButtonTapped, hideButtonTapped: input.hideButtonTapped)
    }
}

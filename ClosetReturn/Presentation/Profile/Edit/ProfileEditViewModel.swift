//
//  ProfileEditViewModel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/31/24.
//

import Foundation

import RxSwift
import RxCocoa

final class ProfileEditViewModel: BaseViewModel {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    private var profileImageData: Data?
    private var nickname: String?
    private var phoneNumber: String?
    private var birthday: String?
    
    enum InvalidType {
        case invalidProfile
        case invalidNickname
        case invalidPhoneNumber
        case invalidBirthday
    }
    
    //MARK: - Inputs
    
    struct Input {
        let cancelButtonTapped: ControlEvent<Void>
        let cancelAlertButtonTapped: PublishRelay<Void>
        let selectedImageData: PublishRelay<Data>
        let inputNickname: ControlProperty<String>
        let inputPhoneNumber: ControlProperty<String>
        let inputBirthday: ControlProperty<Date>
        let doneButtonTapped: ControlEvent<Void>
    }
    
    //MARK: - Outputs
    
    struct Output {
        let cancelButtonTapped: ControlEvent<Void>
        let executeCancel: PublishRelay<Void>
        let selectedImageData: PublishRelay<Data>
        let nicknameValue: PublishRelay<String>
        let phoneNumberValue: PublishRelay<String>
        let birthdayValue: PublishRelay<String>
        let failedEdit: PublishRelay<InvalidType>
        let succeedEdit: PublishRelay<Void>
        let networkError: PublishRelay<(NetworkError, RouterType)>
    }
    
    //MARK: - Methods
    
    func transform(input: Input) -> Output {
        
        let executeCancel = PublishRelay<Void>()
        let selectedImageData = PublishRelay<Data>()
        let nicknameValue = PublishRelay<String>()
        let phoneNumberValue = PublishRelay<String>()
        let birthdayValue = PublishRelay<String>()
        let failedEdit = PublishRelay<InvalidType>()
        let succeedEdit = PublishRelay<Void>()
        let networkError = PublishRelay<(NetworkError, RouterType)>()
        
        input.cancelAlertButtonTapped
            .bind(to: executeCancel)
            .disposed(by: disposeBag)
        
        input.selectedImageData
            .bind(with: self) { owner, value in
                owner.profileImageData = value
                if let data = owner.profileImageData {
                    selectedImageData.accept(data)
                }
            }
            .disposed(by: disposeBag)
        
        input.inputNickname
            .bind(with: self) { owner, value in
                if value.trimmingCharacters(in: .whitespaces).isEmpty {
                    owner.nickname = nil
                } else {
                    if value.contains(" ") {
                        owner.nickname = nil
                    } else {
                        owner.nickname = value
                    }
                }
                nicknameValue.accept(value)
            }
            .disposed(by: disposeBag)
        
        input.inputPhoneNumber
            .bind(with: self) { owner, value in
                if value.trimmingCharacters(in: .whitespaces).isEmpty {
                    owner.phoneNumber = nil
                } else {
                    if value.contains(" ") {
                        owner.phoneNumber = nil
                    } else {
                        if Int(value) == nil {
                            owner.phoneNumber = nil
                        } else {
                            owner.phoneNumber = value
                        }
                    }
                }
                
                phoneNumberValue.accept(value)
            }
            .disposed(by: disposeBag)
        
        input.inputBirthday
            .skip(1)
            .bind(with: self) { owner, value in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd"
                owner.birthday = dateFormatter.string(from: value)
                
                dateFormatter.dateFormat = "yyyy년 M월 d일"
                let string = dateFormatter.string(from: value)
                birthdayValue.accept(string)
            }
            .disposed(by: disposeBag)
        
        input.doneButtonTapped
            .bind(with: self) { owner, _ in
                
                if owner.profileImageData == nil {
                    failedEdit.accept(.invalidProfile)
                    return
                }
                
                if owner.nickname == nil {
                    failedEdit.accept(.invalidNickname)
                    return
                }
                
                if owner.phoneNumber == nil {
                    failedEdit.accept(.invalidPhoneNumber)
                    return
                }
                
                if owner.birthday == nil {
                    failedEdit.accept(.invalidBirthday)
                    return
                }
                
                NetworkManager.shared.updateProfile(profileImageData: owner.profileImageData ?? Data(), nickname: owner.nickname ?? "", phoneNumber: owner.phoneNumber ?? "", birthday: owner.birthday ?? "")
                    .asObservable()
                    .bind(with: self) { owner, result in
                        switch result {
                        case .success(_):
                            succeedEdit.accept(())
                        case .failure(let error):                        
                            networkError.accept((error, .editProfile))
                        }
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            cancelButtonTapped: input.cancelButtonTapped,
            executeCancel: executeCancel,
            selectedImageData: selectedImageData,
            nicknameValue: nicknameValue,
            phoneNumberValue: phoneNumberValue,
            birthdayValue: birthdayValue,
            failedEdit: failedEdit,
            succeedEdit: succeedEdit,
            networkError: networkError
        )
    }
}

//
//  ProductDetailViewModel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/21/24.
//

import Foundation

import iamport_ios
import RxSwift
import RxCocoa

final class ProductDetailViewModel: BaseViewModel {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    var postID = ""
    private var productPost: ProductPost?
    
    private var productImageList: [Data] = []
    
    var postDeleteSucceed: () -> Void = { }
    
    private var payment: IamportPayment?
    
    //MARK: - Inputs
    
    struct Input {
        let fetchData: PublishRelay<Void>
        let backButtonTapped: ControlEvent<Void>
        let likeButtonTapped: ControlEvent<Void>
        let editMenuButtonTapped: PublishRelay<Void>
        let deleteMenuButtonTapped: PublishRelay<Void>
        let deleteAlertButtonTapped: PublishRelay<Void>
        let commentButtonTapped: ControlEvent<Void>
        let buyButtonTapped: ControlEvent<Void>
        let executePayment: PublishRelay<String>
        let profileTapped: PublishRelay<Void>
    }
    
    //MARK: - Outputs
    
    struct Output {
        let profileImageData: PublishRelay<Data>
        let nickname: PublishRelay<String>
        let title: PublishRelay<String>
        let brand: PublishRelay<String>
        let price: PublishRelay<String>
        let createDate: PublishRelay<String>
        let condition: PublishRelay<String>
        let size: PublishRelay<String>
        let category: PublishRelay<String>
        let content: PublishRelay<String>
        let soldStatus: PublishRelay<Bool>
        let productImageDatas: PublishRelay<[Data]>
        let backButtonTapped: ControlEvent<Void>
        let likeStatus: PublishRelay<Bool>
        let editMenuButtonTapped: PublishRelay<ProductPost>
        let hideMenuButton: PublishRelay<Bool>
        let deleteMenuButtonTapped: PublishRelay<Void>
        let succeedDelete: PublishRelay<Void>
        let commentButtonTapped: PublishRelay<ProductPost>
        let buyButtonTapped: PublishRelay<IamportPayment>
        let succeedPayment: PublishRelay<Payments>
        let rejectionEdit: PublishRelay<String>
        let goToProfileDetail: PublishRelay<String>

        let networkError: PublishRelay<(NetworkError, RouterType)>
    }
    
    //MARK: - Methods

    func transform(input: Input) -> Output {
        
        let resultData = PublishSubject<ProductPost>()
        
        let profileImageData = PublishRelay<Data>()
        let nickname = PublishRelay<String>()
        let title = PublishRelay<String>()
        let brand = PublishRelay<String>()
        let price = PublishRelay<String>()
        let createDate = PublishRelay<String>()
        let condition = PublishRelay<String>()
        let size = PublishRelay<String>()
        let category = PublishRelay<String>()
        let content = PublishRelay<String>()
        let soldStatus = PublishRelay<Bool>()
        let productImageDatas = PublishRelay<[Data]>()
        let likeStatus = PublishRelay<Bool>()
        let editMenuButtonTapped = PublishRelay<ProductPost>()
        let hideMenuButton = PublishRelay<Bool>()
        let succeedDelete = PublishRelay<Void>()
        let commentButtonTapped = PublishRelay<ProductPost>()
        let buyButtonTapped = PublishRelay<IamportPayment>()
        let succeedPayment = PublishRelay<Payments>()
        let rejectionEdit = PublishRelay<String>()
        let profileImageTapped = PublishRelay<String>()
        
        let networkError = PublishRelay<(NetworkError, RouterType)>()
        
        
        input.fetchData
            .map { [weak self] _ in
                guard let self else { return "" }
                return self.postID
            }
            .filter { !$0.isEmpty }
            .flatMap { NetworkManager.shared.performRequest(api: .postDetail(postID: $0), model: ProductPost.self) }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let data):
                    owner.productPost = data
                    resultData.onNext(data)
                    
                    if data.creator.user_id == UserDefaultsManager.shared.userID {
                        hideMenuButton.accept(false)
                    } else {
                        hideMenuButton.accept(true)
                    }
                    
                case .failure(let error):
                    networkError.accept((error, RouterType.postDetail))
                    hideMenuButton.accept(true)
                }
                
                if UserDefaultsManager.shared.likeProducts[owner.postID] != nil {
                    likeStatus.accept(true)
                } else {
                    likeStatus.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        let product = resultData.share()
        
        //상품 이미지들
        product
            .map { $0.files }
            .filter { !$0.isEmpty}
            .subscribe(with: self) { owner, path in
                
                owner.productImageList = []
                
                for path in path {
                    NetworkManager.shared.fetchImageData(imagePath: path) { result in
                        switch result {
                        case .success(let value):
                            owner.productImageList.append(value)
                            productImageDatas.accept(owner.productImageList)
                        case .failure(let error):
                            print("Error: 이미지 조회 API 실패")
                            print(error)
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        
        
        //프로필 이미지
        product
            .map { $0.creator.profileImage }
            .subscribe(with: self) { owner, path in
                if let safePath = path {
                    NetworkManager.shared.fetchImageData(imagePath: safePath) { result in
                        switch result {
                        case .success(let value):
                            profileImageData.accept(value)
                        case .failure(let error):
                            print("Error: 이미지 조회 API 실패")
                            print(error)
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        product
            .map { $0.creator.nick }
            .bind(to: nickname)
            .disposed(by: disposeBag)
        
        product
            .map { $0.title }
            .bind(to: title)
            .disposed(by: disposeBag)
        
        product
            .map { $0.content3 }
            .bind(to: brand)
            .disposed(by: disposeBag)
        
        product
            .map { $0.price }
            .map({ number in
                if number == nil {
                    return "가격 미정"
                } else {
                    return (number?.formatted() ?? "0") + "원"
                }
            })
            .bind(to: price)
            .disposed(by: disposeBag)
        
        product
            .map { $0.createDateString }
            .map { "등록일: \($0)"}
            .bind(to: createDate)
            .disposed(by: disposeBag)
        
        product
            .map { $0.content4 }
            .bind { value in
                switch value {
                case "S": condition.accept("새 상품")
                case "A": condition.accept("새 상품에 가까운 깨끗한 상품")
                case "B": condition.accept("사용감이 있는 깨끗한 상품")
                case "C": condition.accept("사용감이 있고 손상이 있는 상품")
                default: condition.accept("정보없음")
                }
            }
            .disposed(by: disposeBag)
        
        product
            .map { $0.content1 }
            .bind(to: size)
            .disposed(by: disposeBag)
        
        product
            .map { $0.content }
            .bind(to: content)
            .disposed(by: disposeBag)
        
        product
            .map { $0.content2 }
            .bind(to: category)
            .disposed(by: disposeBag)
        
        product
            .map { $0.buyers.isEmpty }
            .bind(to: soldStatus)
            .disposed(by: disposeBag)
        
        input.likeButtonTapped
            .bind(with: self) {owner, _ in
                
                var newValue: Bool
                
                if UserDefaultsManager.shared.likeProducts[owner.postID] != nil {
                    newValue = false
                } else {
                    newValue = true
                }
                
                NetworkManager.shared.performRequest(api: .like(postID: owner.postID, isLike: newValue), model: [String: Bool].self)
                    .asObservable()
                    .bind(with: self) { owner, result in
                        switch result {
                        case .success(_):
                            if newValue {
                                UserDefaultsManager.shared.likeProducts[owner.postID] = true
                                likeStatus.accept(true)
                            } else {
                                UserDefaultsManager.shared.likeProducts.removeValue(forKey: owner.postID)
                                likeStatus.accept(false)
                            }
                            
                        case .failure(let error):
                            networkError.accept((error, RouterType.like))
                        }
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        input.editMenuButtonTapped
            .bind(with: self) { owner, _ in
                if let data = owner.productPost {
                    
                    if data.buyers.isEmpty {
                        editMenuButtonTapped.accept(data)
                    } else {
                        rejectionEdit.accept("수정")
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.deleteAlertButtonTapped
            .bind(with: self) { owner, _ in
                
                if let data = owner.productPost {
                    if data.buyers.isEmpty {
                        NetworkManager.shared.performDeleteReuqest(api: .postDelete(postID: owner.postID))
                            .asObservable()
                            .bind(onNext: { result in
                                switch result {
                                case .success(_):
                                    succeedDelete.accept(())
                                case .failure(let error):
                                    networkError.accept((error, RouterType.postDelete))
                                }
                            })
                            .disposed(by: owner.disposeBag)
                    } else {
                        rejectionEdit.accept("삭제")
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.commentButtonTapped
            .bind(with: self) { owner, _ in
                if let data = owner.productPost {
                    commentButtonTapped.accept(data)
                }
            }
            .disposed(by: disposeBag)
        
        input.buyButtonTapped
            .bind(with: self) { owner, _ in
                
                guard let productPost = owner.productPost else { return }
                guard let price = productPost.price else { return }
                
                let payment = IamportPayment(pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"), merchant_uid: "ios_\(APIKey.sesacKey)_\(Int(Date().timeIntervalSince1970))", amount: "\(price)")
                
                payment.pay_method = PayMethod.card.rawValue
                payment.name = productPost.title
                payment.buyer_name = "권대윤"
                payment.app_scheme = "closetreturn"
                
                buyButtonTapped.accept(payment)
            }
            .disposed(by: disposeBag)
        
        input.executePayment
            .bind(with: self) { owner, impUID in
                NetworkManager.shared.performRequest(api: .paymentsValid(imp_uid: impUID, post_id: owner.postID), model: Payments.self)
                    .asObservable()
                    .bind(with: self) { owner, result in
                        switch result {
                        case .success(let data):
                            succeedPayment.accept(data)
                        case .failure(let error):
                            networkError.accept((error, RouterType.paymentsValid))
                        }
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        input.profileTapped
            .bind(with: self) { owner, _ in
                if let userID = owner.productPost?.creator.user_id {
                    profileImageTapped.accept(userID)
                }
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            profileImageData: profileImageData,
            nickname: nickname,
            title: title,
            brand: brand,
            price: price,
            createDate: createDate,
            condition: condition,
            size: size,
            category: category,
            content: content,
            soldStatus: soldStatus,
            productImageDatas: productImageDatas,
            backButtonTapped: input.backButtonTapped,
            likeStatus: likeStatus,
            editMenuButtonTapped: editMenuButtonTapped,
            hideMenuButton: hideMenuButton,
            deleteMenuButtonTapped: input.deleteMenuButtonTapped,
            succeedDelete: succeedDelete,
            commentButtonTapped: commentButtonTapped,
            buyButtonTapped: buyButtonTapped,
            succeedPayment: succeedPayment,
            rejectionEdit: rejectionEdit,
            goToProfileDetail: profileImageTapped,
            networkError: networkError
        )
    }
}

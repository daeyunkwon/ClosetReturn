//
//  ProductDetailViewModel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/21/24.
//

import Foundation

import RxSwift
import RxCocoa

final class ProductDetailViewModel: BaseViewModel {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    var postID = ""
    
    private var productImageList: [Data] = []
    
    //MARK: - Inputs
    
    struct Input {
        let fetchData: PublishRelay<Void>
        let backButtonTapped: ControlEvent<Void>
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
        let productImageDatas: PublishRelay<[Data]>
        let backButtonTapped: ControlEvent<Void>

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
        let productImageDatas = PublishRelay<[Data]>()
        
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
                    resultData.onNext(data)
                case .failure(let error):
                    networkError.accept((error, RouterType.postDetail))
                }
            }
            .disposed(by: disposeBag)
        
        let product = resultData.share()
        
        //상품 이미지들
        product
            .map { $0.files }
            .filter { !$0.isEmpty}
            .subscribe(with: self) { owner, path in
                
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
            productImageDatas: productImageDatas,
            backButtonTapped: input.backButtonTapped,
            networkError: networkError
        )
    }
}

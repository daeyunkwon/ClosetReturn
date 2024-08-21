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
    
    var product: ProductPost?
    
    
    //MARK: - Inputs
    
    struct Input {
        
    }
    
    //MARK: - Outputs
    
    struct Output {
        
    }
    
    //MARK: - Methods

    func transform(input: Input) -> Output {
        
        
        
        BehaviorRelay(value: self.product)
        
        
        
        return Output()
    }
}

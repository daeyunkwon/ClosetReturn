//
//  ProductPostEditViewModel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/23/24.
//

import Foundation

import RxSwift
import RxCocoa

final class ProductPostEditViewModel: BaseViewModel {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Inputs
    
    struct Input {
        let cancelButtonTapped: ControlEvent<Void>
    }
    
    //MARK: - Outputs
    
    struct Output {
        let cancelButtonTapped: ControlEvent<Void>
    }
    
    //MARK: - Methods

    func transform(input: Input) -> Output {
        
        
        
        
        return Output(
            cancelButtonTapped: input.cancelButtonTapped
        )
    }
}

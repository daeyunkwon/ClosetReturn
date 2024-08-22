//
//  ProductPostEditViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/22/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class ProductPostEditViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    private let viewModel: any BaseViewModel
    
    //MARK: - Init
    
    init(viewModel: any BaseViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Components
    
    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.titleLabel?.font = Constant.Font.buttonLargeTitleFont
        btn.tintColor = Constant.Color.Button.cancelColor
        return btn
    }()
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func bind() {
        if let viewModel = viewModel as? ProductPostEditViewModel {
            let input = ProductPostEditViewModel.Input(
                cancelButtonTapped: cancelButton.rx.tap
            )
            let output = viewModel.transform(input: input)
            
            
            
            
            output.cancelButtonTapped
                .bind(with: self) { owner, _ in
                    owner.showEditCancelCheckAlert()
                }
                .disposed(by: disposeBag)
            
            
            
        }
    }
    
    override func configureHierarchy() {
        view.addSubviews(
            cancelButton
        )
    }
    
    override func configureLayout() {
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
    
    //MARK: - Methods
    

    
}

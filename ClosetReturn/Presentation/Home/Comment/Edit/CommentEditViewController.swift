//
//  CommentEditViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/25/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class CommentEditViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let viewModel: CommentEditViewModel
    
    //MARK: - Init
    
    init(viewModel: CommentEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let inputTextView = PlaceholderTextView(placeholder: "메시지 입력")
    
    private let doneButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("완료", for: .normal)
        btn.titleLabel?.font = Constant.Font.buttonLargeTitleFont
        btn.tintColor = Constant.Color.Button.cancelColor
        return btn
    }()
    
    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("취소", for: .normal)
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
        
        let input = CommentEditViewModel.Input(
            comment: inputTextView.rx.text.orEmpty,
            cancelButtonTapped: cancelButton.rx.tap,
            doneButtonTapped: doneButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        output.comment
            .bind(with: self) { owner, value in
                owner.inputTextView.text = value
                if value.trimmingCharacters(in: .whitespaces).isEmpty {
                    owner.inputTextView.placeholderLabel.isHidden = false
                } else {
                    owner.inputTextView.placeholderLabel.isHidden = true
                }
            }
            .disposed(by: disposeBag)
        
        output.cancelButtonTapped
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.commnetModifySucceed
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.networkError
            .bind(with: self) { owner, value in
                owner.showNetworkRequestFailAlert(errorType: value.0, routerType: value.1)
            }
            .disposed(by: disposeBag)
    }
    
    override func setupNavi() {
        navigationItem.title = "댓글 수정하기"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
    }
    
    override func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(inputTextView)
    }
    
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.width.equalTo(view.frame.size.width)
        }
        
        inputTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
    override func configureUI() {
        super.configureUI()
        inputTextView.isScrollEnabled = false
    }
}

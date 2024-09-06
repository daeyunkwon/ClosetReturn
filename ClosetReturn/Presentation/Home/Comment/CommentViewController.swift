//
//  CommentViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/25/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class CommentViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let viewModel: CommentViewModel
    
    //MARK: - Init
    
    init(viewModel: CommentViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Components
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        tv.rowHeight = UITableView.automaticDimension
        return tv
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.backgroundColor = Constant.Color.View.viewBackgroundColor
        view.layer.borderColor = Constant.Color.Button.buttonDisabled.cgColor
        return view
    }()
    
    private let inputTextView = PlaceholderTextView(placeholder: "메시지 입력")
    
    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = Constant.Color.brandColor
        btn.setImage(UIImage(systemName: "paperplane.circle.fill")?.applyingSymbolConfiguration(.init(font: .boldSystemFont(ofSize: 20))), for: .normal)
        btn.isEnabled = false
        return btn
    }()
    
    
    //MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func bind() {
        
        let fetchPorfileImage = PublishRelay<(Int, String)>()
        let alertDeleteButtonTapped = PublishRelay<String>()
        
        let input = CommentViewModel.Input(
            fetchPorfileImage: fetchPorfileImage,
            text: inputTextView.rx.text.orEmpty,
            sendButtonTapped: sendButton.rx.tap,
            alertDeleteButtonTapped: alertDeleteButtonTapped
        )
        let output = viewModel.transform(
            input: input
        )
        
        output.comments
            .map({ value in
                return value.0
            })
            .bind(to: tableView.rx.items(cellIdentifier: CommentTableViewCell.identifier, cellType: CommentTableViewCell.self)) { row, element, cell in
                cell.selectionStyle = .none
                cell.cellConfig(data: element)
                
                if let path = element.creator.profileImage {
                    fetchPorfileImage.accept((row, path))
                }
                
                cell.editButton.rx.tap
                    .bind(with: self) { [weak self] owner, _ in
                        let vm = CommentEditViewModel(comment: cell.commentLabel.text ?? "None", postID: output.comments.value.1, commnetID: element.comment_id)
                        owner.view.endEditing(true)
                        vm.editSucceed = {[weak self] sender in
                            self?.tableView.beginUpdates()
                            cell.commentLabel.text = sender
                            self?.tableView.endUpdates()
                        }
                        let vc = CommentEditViewController(viewModel: vm)
                        let navi = UINavigationController(rootViewController: vc)
                        owner.present(navi, animated: true)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.deleteButton.rx.tap
                    .bind(with: self) { owner, _ in
                        owner.view.endEditing(true)
                        owner.showCommentDeleteCheckAlert { deleteAction in
                            alertDeleteButtonTapped.accept(element.comment_id)
                        }
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.profileImageData
            .bind(with: self) { owner, value in
                if let cell = owner.tableView.cellForRow(at: IndexPath(row: value.0, section: 0)) as? CommentTableViewCell {
                    cell.configureProfileImage(data: value.1)
                }
            }
            .disposed(by: disposeBag)
        
        output.hidePlaceholder
            .bind(to: inputTextView.placeholderLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.sendButtonEnabled
            .bind(to: sendButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.clearText
            .bind(to: inputTextView.rx.text)
            .disposed(by: disposeBag)
        
        
        
        output.networkError
            .bind(with: self) { owner, value in
                owner.showNetworkRequestFailAlert(errorType: value.0, routerType: value.1)
            }
            .disposed(by: disposeBag)
    }
    
    override func setupNavi() {
        navigationItem.title = "댓글"
    }
    
    override func configureHierarchy() {
        view.addSubview(tableView)
        view.addSubview(containerView)
        containerView.addSubviews(sendButton, inputTextView)
    }
    
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-80)
        }
        
        containerView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-3)
            make.height.greaterThanOrEqualTo(30)
        }
        
        sendButton.snp.makeConstraints { make in
            make.size.equalTo(30)
            make.top.equalToSuperview().inset(5)
            make.trailing.equalToSuperview().inset(10)
        }
        
        inputTextView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(5)
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalTo(sendButton.snp.leading).offset(-5)
            make.height.greaterThanOrEqualTo(40)
        }
    }
    
    override func configureUI() {
        super.configureUI()
        inputTextView.isScrollEnabled = false
        inputTextView.iq.enableMode = .disabled
    }
    
    //MARK: - Methods
    
    private func showCommentDeleteCheckAlert(completionHandler: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: "댓글 삭제", message: "해당 댓글을 삭제할까요?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "삭제하기", style: .default, handler: completionHandler))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        self.present(alert, animated: true)
    }
}

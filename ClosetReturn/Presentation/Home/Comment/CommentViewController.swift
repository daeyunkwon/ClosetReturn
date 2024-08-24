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
    private let viewModel = CommentViewModel()
    
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
            make.bottom.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
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
    }
}

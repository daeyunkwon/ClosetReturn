//
//  HomeViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/19/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class HomeViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let viewModel = HomeViewModel()
    
    //MARK: - UI Components
    
    private let navigationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "옷장리턴"
        label.font = Constant.Font.brandFont
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        tv.rowHeight = 210
        return tv
    }()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func bind() {
        let likeButtonTap = PublishRelay<(String, Bool, Int)>()
        
        let input = HomeViewModel.Input(
            cellWillDisplay: tableView.rx.willDisplayCell,
            cellLikeButtonTap: likeButtonTap
        )
        let output = viewModel.transform(input: input)
            
        
        output.productPosts
            .bind(to: tableView.rx.items(cellIdentifier: HomeTableViewCell.identifier, cellType: HomeTableViewCell.self)) { row, element, cell in

                cell.cellConfig(data: element)
                cell.selectionStyle = .none
                
                cell.likeButton.rx.tap
                    .bind(with: self) { owner, _ in
                        cell.likeButton.isUserInteractionEnabled = false
                        
                        var newValue: Bool
                        
                        if UserDefaultsManager.shared.likeProducts[element.post_id] != nil {
                            newValue = false
                        } else {
                            newValue = true
                        }
                        
                        likeButtonTap.accept((element.post_id, newValue, row))
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.likeStatus
            .bind(with: self) { owner, value in
                let indexPath = IndexPath(row: value.1, section: 0)
                if let cell = owner.tableView.cellForRow(at: indexPath) as? HomeTableViewCell {
                    cell.updateAppearanceLikeButton(isLiked: value.0)
                    cell.likeButton.isUserInteractionEnabled = true
                }
            }
            .disposed(by: disposeBag)
        
        output.networkError
            .bind(with: self) { owner, value in
                owner.showNetworkRequestFailAlert(errorType: value.0, routerType: value.1)
            }
            .disposed(by: disposeBag)
    }
    
    override func setupNavi() {
        navigationItem.title = ""
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.navigationTitleLabel)
    }
    
    override func configureHierarchy() {
        view.addSubview(tableView)
    }
    
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.top.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
}

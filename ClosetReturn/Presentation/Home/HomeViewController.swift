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
        let input = HomeViewModel.Input(
            cellWillDisplay: tableView.rx.willDisplayCell
        )
        let output = viewModel.transform(input: input)
        
        
        output.productPosts
            .bind(to: tableView.rx.items(cellIdentifier: HomeTableViewCell.identifier, cellType: HomeTableViewCell.self)) { row, element, cell in
                cell.cellConfig(data: element)
                
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        output.networkError
            .bind(with: self) { owner, networkError in
                owner.showNetworkRequestFailAlert(errorType: networkError)
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

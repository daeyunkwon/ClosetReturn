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
    
    
    
    //MARK: - UI Components
    
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        
    }
    
    override func configureLayout() {
        
    }
    
    override func configureUI() {
        super.configureUI()
        print(UserDefaultsManager.shared.accessToken)
        print(UserDefaultsManager.shared.refreshToken)
    }
}

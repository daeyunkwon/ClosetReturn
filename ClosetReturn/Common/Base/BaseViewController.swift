//
//  BaseViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/15/24.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavi()
        configureHierarchy()
        configureLayout()
        configureUI()
        bind()
    }
    
    func setupNavi() { }
    
    func configureHierarchy() { }
    
    func configureLayout() { }
    
    func configureUI() { view.backgroundColor = Constant.Color.View.viewBackgroundColor }
    
    func bind() { }
    
    func pushViewController(_ vc: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(vc, animated: animated)
    }
    
    func popViewController(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    func setRootViewController(_ viewController: UIViewController) {
        if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = scene.window {
            
            window.rootViewController = viewController
            
            UIView.transition(with: window, duration: 0.2, options: [.transitionCrossDissolve], animations: nil, completion: nil)
        }
    }
}

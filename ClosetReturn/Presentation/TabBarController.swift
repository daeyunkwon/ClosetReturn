//
//  TabBarController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/15/24.
//

import UIKit

final class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupTabBar()
    }
    
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = Constant.Color.Icon.primaryColor
    }
    
    private func setupTabBar() {
        
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        homeVC.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        homeVC.tabBarItem.tag = 0
        
        
        let dummy2 = UINavigationController(rootViewController: UIViewController())
        dummy2.tabBarItem = UITabBarItem(title: "피드", image: UIImage(systemName: "doc.richtext"), selectedImage: UIImage(systemName: "doc.richtext.fill"))
        dummy2.tabBarItem.tag = 1
        
        let dummy3 = UINavigationController(rootViewController: UIViewController())
        dummy3.tabBarItem = UITabBarItem(title: "좋아요", image: UIImage(systemName: "suit.heart"), selectedImage: UIImage(systemName: "suit.heart.fill"))
        dummy3.tabBarItem.tag = 2
        
        let dummy4 = UINavigationController(rootViewController: UIViewController())
        dummy4.tabBarItem = UITabBarItem(title: "나", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        dummy4.tabBarItem.tag = 3
        
        [homeVC, dummy2, dummy3, dummy4].forEach {
            $0.view.backgroundColor = .white
        }
        
        self.setViewControllers([homeVC, dummy2, dummy3, dummy4], animated: false)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let tabBarButton = tabBar.subviews.compactMap({ $0 as? UIControl })[item.tag]
        tabBarButton.bounce()
    }
}

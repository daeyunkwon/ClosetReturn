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
        
        
        let feedVC = UINavigationController(rootViewController: FeedViewController())
        feedVC.tabBarItem = UITabBarItem(title: "피드", image: UIImage(systemName: "doc.richtext"), selectedImage: UIImage(systemName: "doc.richtext.fill"))
        feedVC.tabBarItem.tag = 1
        
        let likeVC = UINavigationController(rootViewController: LikeViewController())
        likeVC.tabBarItem = UITabBarItem(title: "좋아요", image: UIImage(systemName: "suit.heart"), selectedImage: UIImage(systemName: "suit.heart.fill"))
        likeVC.tabBarItem.tag = 2
        
        let profileVC = UINavigationController(rootViewController: ProfileViewController(viewModel: ProfileViewModel(viewType: .loginUser, userID: UserDefaultsManager.shared.userID)))
        profileVC.tabBarItem = UITabBarItem(title: "프로필", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        profileVC.tabBarItem.tag = 3
        
        [homeVC, feedVC, likeVC, profileVC].forEach {
            $0.view.backgroundColor = .white
        }
        
        self.setViewControllers([homeVC, feedVC, likeVC, profileVC], animated: false)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let tabBarButton = tabBar.subviews.compactMap({ $0 as? UIControl })[item.tag]
        tabBarButton.bounce()
    }
}

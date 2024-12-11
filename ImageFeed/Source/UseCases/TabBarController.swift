//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 25/11/2024.
//

import Foundation
import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Initializers
    init() {
        super.init(nibName: nil, bundle: nil)
        setupTabBar()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTabBar()
    }
    
    // MARK: - Private Methods
    private func setupTabBar() {
        
        tabBar.barTintColor = .ypBlack
        tabBar.unselectedItemTintColor = .gray
        tabBar.tintColor = .white
        
        let imagesListViewController = ImagesListViewController()
        imagesListViewController.tabBarItem = UITabBarItem(title: "",
                                                           image: UIImage(systemName: "square.stack.fill"),
                                                           selectedImage: nil)
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(title: "",
                                                        image: UIImage(systemName: "person.circle.fill"),
                                                        selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
    
}

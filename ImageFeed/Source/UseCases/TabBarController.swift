//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 25/11/2024.
//

import Foundation
import UIKit

final class TabBarController: UITabBarController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
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

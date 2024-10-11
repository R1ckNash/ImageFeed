//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 11/10/2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var avatarImageview: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var loginNameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    @IBOutlet private weak var logoutButton: UIButton!
    
    //MARK: - IBActions
    @IBAction private func didTapLogoutButton(_ sender: Any) {
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

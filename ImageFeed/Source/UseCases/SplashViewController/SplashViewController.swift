//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 12/11/2024.
//

import UIKit

final class SplashViewController: UIViewController {
    
    //MARK: - Private Properties
    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    //MARK: - SplashViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        let imageView = UIImageView(image: .init(named: "splash_screen_logo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            self.fetchProfile(token)
        } else {
            let authVC = AuthViewController()
            authVC.delegate = self
            authVC.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(authVC, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    //MARK: - Public Methods
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    //MARK: - Private Methods
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = TabBarController()
        
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(_ token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profileService.profile = .init(from: profile)
                self.profileImageService.fetchProfileImageUrl(profile.username, token) { _ in }
                self.switchToTabBarController()
            case .failure(let error):
                fatalError("Fetching profile failed - \(error.localizedDescription)")
            }
        }
    }
}

//MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    
    func didAuthenticate(_ vc: AuthViewController) {
        self.navigationController?.popViewController(animated: true)
        if let token = oauth2TokenStorage.token {
            self.fetchProfile(token)
        }
    }
    
}

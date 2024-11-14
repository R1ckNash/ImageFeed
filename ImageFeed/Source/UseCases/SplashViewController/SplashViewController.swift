//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 12/11/2024.
//

import UIKit

final class SplashViewController: UIViewController {
    
    //MARK: - Private Properties
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2Service = OAuth2Service.shared
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
        
        if oauth2TokenStorage.token != nil {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    //MARK: - Private Methods
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure:
                break
            }
        }
    }
    
}

//MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    
    func didAuthenticate(_ vc: AuthViewController) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.switchToTabBarController()
        }
    }
    
}

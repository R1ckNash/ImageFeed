//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 11/10/2024.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfileDetails(name: String, loginName: String, bio: String?)
    func updateAvatar(imageURL: URL?)
    func showLogoutConfirmation()
    func showError(message: String)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    // MARK: - Visual Components
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton()
    
    // MARK: - Private Properties
    private var profileImageServiceObserver: NSObjectProtocol?
    private var animationLayers = Set<CALayer>()
    
    // MARK: - Public Properties
    var presenter: ProfilePresenterProtocol?
    
    // MARK: - Public Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        presenter?.updateProfileDetails()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.presenter?.updateAvatar()
            }
        
        presenter?.updateAvatar()
    }
    
    func updateAvatar(imageURL: URL?) {
        animationLayers.removeAll()
        guard let url = imageURL else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "Photo"),
                                    options: [.processor(processor)])
    }
    
    func updateProfileDetails(name: String, loginName: String, bio: String?) {
        removeAnimations()
        nameLabel.text = name
        loginNameLabel.text = loginName
        descriptionLabel.text = bio
    }
    
    func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Bye bye!",
            message: "Are you sure?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.presenter?.didConfirmLogout()
        })
        
        present(alert, animated: true)
    }
    
    func showError(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Private Methods
    @objc private func didTapLogoutButton() {
        presenter?.didTapLogout()
    }
    
    private func configureUI() {
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
        
        configureBackground()
        configureAvatarImageview()
        configureNameLabel()
        configureLoginNameLabel()
        configureDescriptionLabel()
        configureLogoutButton()
    }
    
    private func configureBackground() {
        view.backgroundColor = .ypBlack
    }
    
    private func addGradient(to view: UIView, cornerRadius: CGFloat = 0) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0.7, 0.8, 1]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: "locationsAnimation")
        
        view.layer.addSublayer(gradient)
        animationLayers.insert(gradient)
    }
    
    private func removeAnimations() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
    }
    
    private func configureUIWithAnimations() {
        addGradient(to: avatarImageView, cornerRadius: 35)
        addGradient(to: nameLabel)
        addGradient(to: loginNameLabel)
        addGradient(to: descriptionLabel)
    }
    
    private func configureAvatarImageview() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.image = UIImage(imageLiteralResourceName: "Photo")
        avatarImageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
        ])
    }
    
    private func configureNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Ekaterina Novikova"
        nameLabel.font = .systemFont(ofSize: 23, weight: .semibold)
        nameLabel.textColor = .white
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
        ])
    }
    
    private func configureLoginNameLabel() {
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.font = .systemFont(ofSize: 13)
        loginNameLabel.textColor = .ypGray
        
        NSLayoutConstraint.activate([
            loginNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
        ])
    }
    
    private func configureDescriptionLabel() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .white
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
        ])
    }
    
    private func configureLogoutButton() {
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setImage(UIImage(imageLiteralResourceName: "logout_button"), for: .normal)
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        logoutButton.accessibilityIdentifier = "logout button"
        
        NSLayoutConstraint.activate([
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: logoutButton.trailingAnchor, constant: 16),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
}

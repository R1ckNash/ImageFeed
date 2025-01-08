//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 02/01/2025.
//

import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func updateProfileDetails()
    func updateAvatar()
    func didTapLogout()
    func didConfirmLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: - Public Properties
    
    weak var view: ProfileViewControllerProtocol?
    
    // MARK: - Private Properties
    
    private let profileService: ProfileServiceProtocol
    private let logoutService: ProfileLogoutServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    
    // MARK: - Initializers
    
    init(profileService: ProfileServiceProtocol, logoutService: ProfileLogoutServiceProtocol, profileImageService: ProfileImageServiceProtocol) {
        self.profileService = profileService
        self.logoutService = logoutService
        self.profileImageService = profileImageService
    }
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        updateProfileDetails()
        updateAvatar()
    }
    
    func updateProfileDetails() {
        guard let profile = profileService.profile else {
            view?.showError(message: "Failed to load profile")
            return
        }
        
        view?.updateProfileDetails(name: profile.name,
                                        loginName: profile.loginName,
                                        bio: profile.bio)
    }
    
    func updateAvatar() {
        guard let profileImageURL = profileImageService.avatarURL,
              let url = URL(string: profileImageURL) else {
            return
        }
        
        view?.updateAvatar(imageURL: url)
    }
    
    func didTapLogout() {
        view?.showLogoutConfirmation()
    }
    
    func didConfirmLogout() {
        logoutService.logout()
    }
}

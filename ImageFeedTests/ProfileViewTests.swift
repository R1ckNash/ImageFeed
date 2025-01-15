//
//  ProfileViewTests.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 02/01/2025.
//

@testable import ImageFeed
import XCTest

// MARK: - Mocks and Spies
final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var didCallUpdateProfileDetails = false
    var didCallUpdateAvatar = false
    var didCallShowLogoutConfirmation = false
    var didCallShowError = false
    var receivedErrorMessage: String?
    
    func updateProfileDetails(name: String, loginName: String, bio: String?) {
        didCallUpdateProfileDetails = true
    }
    
    func updateAvatar(imageURL: URL?) {
        didCallUpdateAvatar = true
    }
    
    func showLogoutConfirmation() {
        didCallShowLogoutConfirmation = true
    }
    
    func showError(message: String) {
        didCallShowError = true
        receivedErrorMessage = message
    }
}

final class ProfileServiceMock: ProfileServiceProtocol {
    
    func fetchProfile(_ code: String, completion: @escaping (Result<ProfileResult, any Error>) -> Void) {
        
    }
    
    var profile: Profile?
}

final class ProfileImageServiceMock: ProfileImageServiceProtocol {
    var avatarURL: String?
    
    func fetchProfileImageUrl(_ username: String, _ token: String, completion: @escaping (Result<ImageFeed.UserResult, any Error>) -> Void) {
    }
}

final class ProfileLogoutServiceMock: ProfileLogoutServiceProtocol {
    var didCallLogout = false
    
    func logout() {
        didCallLogout = true
    }
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    var didCallUpdateProfileDetails = false
    var didCallUpdateAvatar = false
    
    func viewDidLoad() {
        didCallUpdateProfileDetails = true
        didCallUpdateAvatar = true
    }
    
    func updateProfileDetails() {
        didCallUpdateProfileDetails = true
    }
    
    func updateAvatar() {
        didCallUpdateAvatar = true
    }
    
    func didTapLogout() {}
    func didConfirmLogout() {}
}

// MARK: - ProfilePresenter Tests
final class ProfilePresenterTests: XCTestCase {
    
    func testViewDidLoadCallsUpdateMethods() {
        
        // given
        let profileService = ProfileServiceMock()
        profileService.profile = Profile(username: "@TestName", name: "Test Name", loginName: "test_login", bio: "Test Bio")
        let logoutService = ProfileLogoutServiceMock()
        let viewController = ProfileViewControllerSpy()
        let profileImageService = ProfileImageServiceMock()
        profileImageService.avatarURL = "https://example.com/avatar.jpg"
        let presenter = ProfilePresenter(profileService: profileService, logoutService: logoutService, profileImageService: profileImageService)
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewController.didCallUpdateProfileDetails)
        XCTAssertTrue(viewController.didCallUpdateAvatar)
    }
    
    func testUpdateProfileDetailsShowsErrorIfNoProfile() {
        
        // given
        let profileService = ProfileServiceMock()
        profileService.profile = nil
        let logoutService = ProfileLogoutServiceMock()
        let profileImageService = ProfileImageServiceMock()
        let presenter = ProfilePresenter(profileService: profileService,
                                         logoutService: logoutService,
                                         profileImageService: profileImageService)
        let view = ProfileViewControllerSpy()
        presenter.view = view
        
        // when
        presenter.updateProfileDetails()
        
        // then
        XCTAssertTrue(view.didCallShowError)
        XCTAssertEqual(view.receivedErrorMessage, "Failed to load profile")
    }
    
    func testUpdateProfileDetailsUpdatesViewIfProfileExists() {
        
        // given
        let profileService = ProfileServiceMock()
        profileService.profile = Profile(username: "@TestName", name: "Test Name", loginName: "test_login", bio: "Test Bio")
        let logoutService = ProfileLogoutServiceMock()
        let profileImageService = ProfileImageServiceMock()
        let presenter = ProfilePresenter(profileService: profileService,
                                         logoutService: logoutService,
                                         profileImageService: profileImageService)
        let view = ProfileViewControllerSpy()
        presenter.view = view
        
        // when
        presenter.updateProfileDetails()
        
        // then
        XCTAssertTrue(view.didCallUpdateProfileDetails)
    }
    
    func testDidTapLogoutCallsShowLogoutConfirmation() {
        
        // given
        let profileService = ProfileServiceMock()
        let logoutService = ProfileLogoutServiceMock()
        let profileImageService = ProfileImageServiceMock()
        let presenter = ProfilePresenter(profileService: profileService,
                                         logoutService: logoutService,
                                         profileImageService: profileImageService)
        let view = ProfileViewControllerSpy()
        view.presenter = presenter
        presenter.view = view
        
        // when
        presenter.didTapLogout()
        
        // then
        XCTAssertTrue(view.didCallShowLogoutConfirmation)
    }
    
    func testDidConfirmLogoutCallsLogoutService() {
        
        // given
        let profileService = ProfileServiceMock()
        let logoutService = ProfileLogoutServiceMock()
        let profileImageService = ProfileImageServiceMock()
        let presenter = ProfilePresenter(profileService: profileService,
                                         logoutService: logoutService,
                                         profileImageService: profileImageService)
        
        // when
        presenter.didConfirmLogout()
        
        // then
        XCTAssertTrue(logoutService.didCallLogout)
    }
}

// MARK: - ProfileViewController Tests
final class ProfileViewControllerTests: XCTestCase {
    
    func testViewControllerCallsPresenterUpdateMethods() {
        
        // given
        let viewController = ProfileViewController()
        let presenterSpy = ProfilePresenterSpy()
        viewController.presenter = presenterSpy
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenterSpy.didCallUpdateProfileDetails)
        XCTAssertTrue(presenterSpy.didCallUpdateAvatar)
    }
}

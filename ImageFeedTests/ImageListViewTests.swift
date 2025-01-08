//
//  ImageListViewTests.swift
//  ImageFeedTests
//
//  Created by Ilia Liasin on 03/01/2025.
//

@testable import ImageFeed
import XCTest

final class ImagesListServiceMock: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var didFetchPhotosNextPage = false
    
    func fetchPhotosNextPage(_ token: String) {
        didFetchPhotosNextPage = true
    }
    
    func changeLike(_ token: String,
                    photoId: String,
                    isLike: Bool,
                    _ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
}

final class OAuth2TokenStorageMock: OAuth2TokenStorageProtocol {
    func cleanStorage() {}
    
    var token: String? = "mockToken"
}

final class ImagesListViewControllerMock: ImagesListViewControllerProtocol {
    var didUpdateTableViewAnimated = false
    var didShowError = false
    var lastErrorMessage: String?
    
    func updateTableViewAnimated(_ oldCount: Int, _ newCount: Int) {
        didUpdateTableViewAnimated = true
    }
    
    func showError(_ message: String) {
        didShowError = true
        lastErrorMessage = message
    }
}

final class ImageListViewTests: XCTestCase {
    var presenter: ImagesListPresenter!
    var viewMock: ImagesListViewControllerMock!
    var serviceMock: ImagesListServiceMock!
    var tokenStorageMock: OAuth2TokenStorageMock!
    
    override func setUp() {
        super.setUp()
        serviceMock = ImagesListServiceMock()
        tokenStorageMock = OAuth2TokenStorageMock()
        viewMock = ImagesListViewControllerMock()
        presenter = ImagesListPresenter(imagesListService: serviceMock, tokenStorage: tokenStorageMock)
        presenter.view = viewMock
    }
    
    override func tearDown() {
        presenter = nil
        viewMock = nil
        serviceMock = nil
        tokenStorageMock = nil
        super.tearDown()
    }
    
    func testViewDidLoadFetchesPhotos() {
        presenter.viewDidLoad()
        XCTAssertTrue(serviceMock.didFetchPhotosNextPage)
    }
    
    func testUpdateTableViewAnimatedCalledWhenPhotosChange() {
        let initialPhotos = [Photo(id: "1", size: .zero, createdAt: nil, welcomeDescription: "", thumbImageURL: "", largeImageURL: "", regularImageURL: "", isLiked: false)]
        serviceMock.photos = initialPhotos
        presenter.viewDidLoad()
        
        let newPhotos = [
            Photo(id: "1", size: .zero, createdAt: nil, welcomeDescription: "", thumbImageURL: "", largeImageURL: "", regularImageURL: "", isLiked: false),
            Photo(id: "2", size: .zero, createdAt: nil, welcomeDescription: "", thumbImageURL: "", largeImageURL: "", regularImageURL: "", isLiked: false)
        ]
        serviceMock.photos = newPhotos
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
        
        XCTAssertTrue(viewMock.didUpdateTableViewAnimated)
    }
    
    func testFetchNextPageIfNeededCallsFetchPhotosNextPage() {
        presenter.fetchNextPageIfNeeded(at: IndexPath(row: 0, section: 0))
        XCTAssertTrue(serviceMock.didFetchPhotosNextPage)
    }
    
}

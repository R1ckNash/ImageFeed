//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 03/01/2025.
//

import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photosCount: Int { get }
    func viewDidLoad()
    func fetchNextPageIfNeeded(at indexPath: IndexPath)
    func didTapLike(for photoId: String, isLiked: Bool, cell: ImagesListCell)
    func photo(at index: Int) -> Photo
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    private let imagesListService: ImagesListServiceProtocol
    private let tokenStorage: OAuth2TokenStorageProtocol
    private var photos: [Photo] = []
    
    private var imagesListServiceObserver: NSObjectProtocol?
    
    var photosCount: Int {
        return photos.count
    }
    
    func photo(at index: Int) -> Photo {
        return photos[index]
    }
    
    init(imagesListService: ImagesListServiceProtocol, tokenStorage: OAuth2TokenStorageProtocol) {
        self.imagesListService = imagesListService
        self.tokenStorage = tokenStorage
    }
    
    func viewDidLoad() {
        observeServiceChanges()
        if let token = tokenStorage.token {
            imagesListService.fetchPhotosNextPage(token)
        }
    }
    
    private func observeServiceChanges() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if oldCount != newCount {
            view?.updateTableViewAnimated(oldCount, newCount)
        }
    }
    
    func fetchNextPageIfNeeded(at indexPath: IndexPath) {
        if let token = tokenStorage.token {
            imagesListService.fetchPhotosNextPage(token)
        }
    }
    
    func didTapLike(for photoId: String, isLiked: Bool, cell: ImagesListCell) {
        guard let token = tokenStorage.token else { return }
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(token, photoId: photoId, isLike: !isLiked) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
                    self?.photos = self?.imagesListService.photos ?? []
                    self?.updateTableViewAnimated()
                    if let updatedPhoto = self?.photos.first(where: { $0.id == photoId }) {
                        cell.setIsLiked(updatedPhoto.isLiked)
                    }
                case .failure(let error):
                    print("Failed to change like status: \(error.localizedDescription)")
                    self?.view?.showError("Failed to update like status. Please try again later.")
                }
            }
        }
    }
}

//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 11/12/2024.
//

import Foundation

protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    func fetchPhotosNextPage(_ token: String)
    func changeLike(_ token: String, photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}

final class ImagesListService: ImagesListServiceProtocol {
    
    // MARK: - Public Properties
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Private Properties
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private let urlSession: URLSession
    private var task: URLSessionTask?
    private var lastToken: String?
    
    // MARK: - Initializers
    init() {
        self.lastLoadedPage = 0
        urlSession = URLSession.shared
    }
    
    // MARK: - Public Methods
    func fetchPhotosNextPage(_ token: String) {
        assert(Thread.isMainThread)
        
        guard lastToken != token else {
            print("Fetch already in progress")
            return
        }
        
        task?.cancel()
        lastToken = token
        
        let nextPage = String((lastLoadedPage ?? 0) + 1)
        
        guard let request = makeImageListRequest(with: nextPage, token: token) else {
            print("Error: Failed to create image request")
            return
        }
        
        print("Fetching image list with request: \(request)")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.task = nil
                self.lastToken = nil
                
                switch result {
                case .success(let photoList):
                    let photos = photoList.map { Photo(from: $0) }
                    self.photos.append(contentsOf: photos)
                    self.lastLoadedPage = (self.lastLoadedPage ?? 0) + 1
                    
                    NotificationCenter.default
                        .post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["Photos": photos])
                    
                case .failure(let error):
                    print("Error during photos loading: \(error)")
                }
            }
        }
        self.task = task
        task.resume()
        
    }
    
    func changeLike(_ token: String, photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastToken != token else {
            print("Fetch already in progress")
            return
        }
        
        task?.cancel()
        lastToken = token
        
        guard let request = makeChangeLikeRequest(token, photoId, isLike) else {
            print("Error: Failed to create change like request")
            return
        }
        
        print("Change like with request: \(request)")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<LikeResponse, Error>) in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.task = nil
                self.lastToken = nil
                
                switch result {
                case .success(_):
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        var photo = self.photos[index]
                        photo.isLiked = isLike
                        self.photos[index] = photo
                    }
                    completion(.success(()))
                case .failure(let error):
                    print("Error during  like changing: \(error)")
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
        
    }
    
    func cleanPhotos() {
        photos.removeAll()
    }
    
    // MARK: - Private Methods
    private func makeImageListRequest(with page: String, token: String) -> URLRequest? {
        
        guard let url = URL(string: "\(Constants.defaultBaseURL)/photos") else {
            print("Error: Invalid URL")
            return nil
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            .init(name: "page", value: page),
            .init(name: "per_page", value: "10"),
        ]
        
        guard let finalURL = urlComponents?.url else {
            print("Error: Invalid final URL")
            return nil
        }
        
        var request = URLRequest(url: finalURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return request
    }
    
    private func makeChangeLikeRequest(_ token: String, _ photoId: String, _ isLike: Bool) -> URLRequest? {
        
        guard let url = URL(string: "\(Constants.defaultBaseURL)/photos/\(photoId)/like") else {
            print("Error: Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = isLike ? "POST" : "DELETE"
        
        return request
    }
}

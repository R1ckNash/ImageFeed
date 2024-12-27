//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 24/11/2024.
//

import Foundation

final class ProfileImageService {
    
    // MARK: - Public Properties
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    var avatarURL: String?
     
    //MARK: - Private Properties
    private let urlSession: URLSession
    private var task: URLSessionTask?
    private var lastToken: String?
    
    // MARK: - Initializers
    private init() {
        urlSession = URLSession.shared
    }
    
    // MARK: - Public Methods
    func fetchProfileImageUrl(_ username: String, _ token: String, completion: @escaping (Result<UserResult, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastToken != token else {
            print("Fetch already in progress")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastToken = token
        
        guard let request = makeProfileImageRequest(with: username, token: token) else {
            print("Error: Failed to create image request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        print("Fetching profile image with request: \(request)")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.task = nil
                self.lastToken = nil
                
                switch result {
                case .success(let profileImageURL):
                    self.avatarURL = profileImageURL.profileImage.small
                    completion(.success(profileImageURL))

                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": profileImageURL])
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
        
    }
    
    // MARK: - Private Methods
    private func makeProfileImageRequest(with username: String, token: String) -> URLRequest? {
        
        guard let url = URL(string: "\(Constants.defaultBaseURL)/users/\(username)") else {
            print("Error: Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return request
    }
}


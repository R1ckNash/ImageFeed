//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 19/11/2024.
//

import Foundation

final class ProfileService {
    
    // MARK: - Public Properties
    static let shared = ProfileService()
    var profile: Profile?
    
    //MARK: - Private Properties
    private let decoder: JSONDecoder
    private let urlSession: URLSession
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Initializers
    private init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        urlSession = URLSession.shared
    }
    
    // MARK: - Public Methods
    func fetchProfile(_ code: String, completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            print("Fetch already in progress")
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeProfileRequest(with: code) else {
            print("Error: Failed to create request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        print("Fetching profile with request: \(request)")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.task = nil
                self.lastCode = nil
                
                switch result {
                case .success(let body):
                    print("Profile fetch success: \(body)")
                    completion(.success(body))
                case .failure(let error):
                    print("Profile fetch failure: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
        
    }
    
    // MARK: - Private Methods
    private func makeProfileRequest(with token: String) -> URLRequest? {
        print("Creating profile request with token: \(token)")
        
        guard let url = URL(string: "\(Constants.defaultBaseURL)/me") else {
            print("Error: Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        return request
    }
}

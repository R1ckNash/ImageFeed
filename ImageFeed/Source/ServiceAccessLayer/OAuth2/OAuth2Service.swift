//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 10/11/2024.
//

import Foundation

final class OAuth2Service {
    
    //MARK: - Public Properties
    static let shared = OAuth2Service()
    
    //MARK: - Private Properties
    private let tokenStorage: OAuth2TokenStorage
    private let decoder: JSONDecoder
    private let urlSession: URLSession
    
    private(set) var authToken: String? {
        get {
            return tokenStorage.token
        }
        set {
            tokenStorage.token = newValue
        }
    }
    
    //MARK: - Initializers
    private init() {
        tokenStorage = OAuth2TokenStorage()
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        urlSession = URLSession.shared
    }
    
    //MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard
            let request = makeOAuthTokenRequest(code: code)
        else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = object(for: request) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completion(.success(authToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            print("Error: Invalid URL")
            return nil
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            .init(name: "client_id", value: Constants.accessKey),
            .init(name: "client_secret", value: Constants.secretKey),
            .init(name: "redirect_uri", value: Constants.redirectURI),
            .init(name: "code", value: code),
            .init(name: "grant_type", value: "authorization_code")
        ]
        
        guard let finalURL = urlComponents?.url else {
            print("Error: Invalid final URL")
            return nil
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "POST"
        
        return request
    }
}

// MARK: - Network Client
extension OAuth2Service {
    
    private func object(for request: URLRequest,
                        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) -> URLSessionTask {
        
        return urlSession.data(for: request) { [weak self] (result: Result<Data, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                do {
                    let body = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(body))
                }
                catch {
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

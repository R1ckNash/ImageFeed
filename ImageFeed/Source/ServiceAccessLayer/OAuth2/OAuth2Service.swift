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
    
    //MARK: - Initializers
    private init() {
        tokenStorage = OAuth2TokenStorage()
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    //MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Error: Invalid request")
            return
        }
        
        URLSession.shared.data(for: request) { [weak self] result in
            guard let self else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            switch result {
            case .success(let data):
                do {
                    let tokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self.tokenStorage.token = tokenResponse.accessToken
                    print("Saved token - \(self.tokenStorage.token ?? "nil")")
                    completion(.success(tokenResponse.accessToken))
                } catch {
                    print("Failed to decode token: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                
            case .failure(let error):
                print("Network error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        .resume()
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

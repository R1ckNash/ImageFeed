//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 10/11/2024.
//

import Foundation

final class OAuth2Service {
    
    //MARK: - Properties
    static let shared = OAuth2Service()
    private let tokenStorage: OAuth2TokenStorage
    
    //MARK: - Lifecycle
    private init() {
        tokenStorage = OAuth2TokenStorage()
    }
    
    //MARK: - Public methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request = makeOAuthTokenRequest(code: code)
        
        URLSession.shared.data(for: request) { [weak self] result in
            guard let self else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            switch result {
            case .success(let data):
                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
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
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
        
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")!
        urlComponents.queryItems = [
            .init(name: "client_id", value: Constants.accessKey),
            .init(name: "client_secret", value: Constants.secretKey),
            .init(name: "redirect_uri", value: Constants.redirectURI),
            .init(name: "code", value: code),
            .init(name: "grant_type", value: "authorization_code"),
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        
        return request
    }
}

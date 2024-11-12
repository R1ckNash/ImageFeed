//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 10/11/2024.
//

import Foundation

final class OAuth2TokenStorage {
    
    //MARK: - Properties
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case bearerToken
    }
    
    var token: String? {
        get {
            return userDefaults.string(forKey: Keys.bearerToken.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.bearerToken.rawValue)
        }
    }
}

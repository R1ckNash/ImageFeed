//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 10/11/2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    //MARK: - Public Properties
    static let shared = OAuth2TokenStorage()
    
    var token: String? {
        get {
            dataStorage.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                dataStorage.set(token, forKey: tokenKey)
            } else {
                dataStorage.removeObject(forKey: tokenKey)
            }
        }
    }
    
    //MARK: - Private Properties
    private let dataStorage = KeychainWrapper.standard
    private let tokenKey = "token"
    
}

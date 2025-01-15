//
//  Constants.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 08/01/2025.
//

import Foundation

enum Constants {
    
    static let accessKey = "0fYcwb-Y32pgIsqNWtwNWUSL1_0YuzODU5UDVn6jqFk"
    static let secretKey = "5KWZb8LxCqJEJ24WYmUGZ5-uxJWyLy3KFFStZ9A1QHo"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

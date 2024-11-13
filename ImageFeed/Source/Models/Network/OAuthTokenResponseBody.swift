//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 10/11/2024.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {

    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}

//
//  UserResult.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 24/11/2024.
//

import Foundation

struct UserResult: Decodable {
    let profileImage: ProfileImage
}

struct ProfileImage: Decodable {
    let small: String
}

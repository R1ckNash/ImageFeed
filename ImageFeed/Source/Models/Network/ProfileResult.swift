//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 19/11/2024.
//

import Foundation

struct ProfileResult: Decodable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
}

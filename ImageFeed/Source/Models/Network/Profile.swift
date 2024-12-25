//
//  Profile.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 19/11/2024.
//

import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
    
    init(from profileResult: ProfileResult) {
        self.username = profileResult.username
        self.name = profileResult.firstName + " " + (profileResult.lastName ?? "")
        self.loginName = "@\(profileResult.username)"
        self.bio = profileResult.bio ?? ""
    }
}


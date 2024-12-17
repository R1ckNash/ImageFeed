//
//  Photo.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 11/12/2024.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let regularImageURL: String
    let isLiked: Bool
    
    
    init(from photoResult: PhotoResult) {
        self.id = photoResult.id
        self.size = .init(width: photoResult.width, height: photoResult.height)
        self.createdAt = photoResult.createdAt
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb
        self.largeImageURL = photoResult.urls.full
        self.regularImageURL = photoResult.urls.regular
        self.isLiked = photoResult.likedByUser
    }
}

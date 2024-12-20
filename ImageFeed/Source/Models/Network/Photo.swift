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
    
    init(id: String, size: CGSize, createdAt: Date, welcomeDescription: String?, thumbImageURL: String, largeImageURL: String, regularImageURL: String, isLiked: Bool) {
        self.id = id
        self.size = size
        self.createdAt = createdAt
        self.welcomeDescription = welcomeDescription
        self.thumbImageURL = thumbImageURL
        self.largeImageURL = largeImageURL
        self.regularImageURL = regularImageURL
        self.isLiked = isLiked
    }
    
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

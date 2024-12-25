//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 17/12/2024.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Double
    let height: Double
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
}

struct UrlsResult: Decodable {
    let full: String
    let thumb: String
    let regular: String
}

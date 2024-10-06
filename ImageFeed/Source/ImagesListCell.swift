//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 06/10/2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    //MARK: - Static
    static let reuseIdentifier = "ImagesListCell"
    
    //MARK: - IBOutlets
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    
}

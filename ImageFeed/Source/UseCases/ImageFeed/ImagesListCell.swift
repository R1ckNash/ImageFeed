//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 06/10/2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var cellImage: UIImageView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    
    //MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
    
    //MARK: - Public Methods
    func configure(with image: UIImage, isLiked: Bool, date: String) {
        cellImage.image = image
        dateLabel.text = date
        
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        likeButton.setImage(likeImage, for: .normal)
    }
    
}

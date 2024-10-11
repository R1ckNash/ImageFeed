//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 11/10/2024.
//

import UIKit

final class SingleImageViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    
    //MARK: - Properties
    private var image: UIImage?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    //MARK: - Public methods
    func setImage(_ image: UIImage?) {
        self.image = image
    }

}

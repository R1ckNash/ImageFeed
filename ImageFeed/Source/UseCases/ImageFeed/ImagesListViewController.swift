//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 26/09/2024.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    // MARK: - Visual Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypBlack
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    // MARK: - Private Properties
    private var photos: [Photo] = []
    
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    // MARK: - ImagesListViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupTableView()
        observeServiceChanges()
        
        if let token = oauth2TokenStorage.token {
            imagesListService.fetchPhotosNextPage(token)
        }
    }
    
    // MARK: - Private Methods
    private func setupTableView() {
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func observeServiceChanges() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount ..< newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        cell.prepareForReuse()
        
        guard let imageURL = URL(string: photo.regularImageURL) else {
            print("Error: Invalid image URL \(photo.regularImageURL)")
            return
        }
        
        cell.configure(
            with: imageURL,
            isLiked: photo.isLiked,
            date: DateFormatterService.shared.format(photo.createdAt)
        )
    }
    
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        guard let token = oauth2TokenStorage.token else { return }
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(token, photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                
                UIBlockingProgressHUD.dismiss()
                switch result {
                    
                case .success:
                    self.photos = self.imagesListService.photos
                    if let updatedIndex = self.photos.firstIndex(where: { $0.id == photo.id }) {
                        let updatedPhoto = self.photos[updatedIndex]
                        cell.setIsLiked(updatedPhoto.isLiked)
                    }
                case .failure(let error):
                    print("Failed to change like status: \(error.localizedDescription)")
                    
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to update like status. Please try again later.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        configCell(for: cell, with: indexPath)
        return cell
    }
    
}
// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        guard let imageURL = URL(string: photo.largeImageURL) else {
            print("Error: Invalid image URL \(photo.largeImageURL)")
            return
        }
        
        let vc = SingleImageViewController()
        vc.setImage(with: imageURL)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            if let token = oauth2TokenStorage.token {
                imagesListService.fetchPhotosNextPage(token)
            }
        }
    }
}

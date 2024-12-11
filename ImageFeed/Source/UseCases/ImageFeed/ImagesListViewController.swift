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
    private let photosName: [String] = Array(0..<20).map { "\($0)" }
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - ImagesListViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
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
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath)  {
        
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        
        let date = dateFormatter.string(from: Date())
        let isLiked = indexPath.row % 2 == 0
        
        cell.configure(with: image, isLiked: isLiked, date: date)
    }

}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: cell, with: indexPath)
        return cell
    }
    
}
// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            print("Error: Could not load image \(photosName[indexPath.row])")
            return
        }
        
        let vc = SingleImageViewController()
        vc.setImage(image)
        vc.modalPresentationStyle = .fullScreen
        
        self.present(vc, animated: true)
    }
    
}

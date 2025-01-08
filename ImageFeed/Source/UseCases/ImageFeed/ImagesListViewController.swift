//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 26/09/2024.
//

import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(_ oldCount: Int, _ newCount: Int)
    func showError(_ message: String)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    // MARK: - UI Components
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypBlack
        tableView.separatorStyle = .none
        return tableView
    }()
    
    // MARK: - Public Properties
    
    var presenter: ImagesListPresenterProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        presenter?.viewDidLoad()
    }
    
    // MARK: - Public Properties
    
    func updateTableViewAnimated(_ oldCount: Int, _ newCount: Int) {
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount ..< newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Private Properties
    
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
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = presenter?.getPhoto(at: indexPath.row)
        cell.prepareForReuse()
        
        guard let photo else {
            print("Error: No photo")
            return
        }
        
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

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photosCount ?? 0
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
        let photo = presenter?.getPhoto(at: indexPath.row)
        
        guard let photo else {
            print("Error: No photo")
            return CGFloat.zero
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = presenter?.getPhoto(at: indexPath.row)
        
        guard let photo else {
            print("Error: No photo")
            return
        }
        
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
        guard !CommandLine.arguments.contains("--disable-pagination") else { return }
        
        if indexPath.row + 1 == presenter?.photosCount {
            presenter?.fetchNextPageIfNeeded(at: indexPath)
        }
    }
}


// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = presenter?.getPhoto(at: indexPath.row)
        
        guard let photo else {
            print("Error: No photo")
            return
        }
        
        presenter?.didTapLike(for: photo.id, isLiked: photo.isLiked, cell: cell)
    }
}

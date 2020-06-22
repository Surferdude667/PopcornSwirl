//
//  MovieViewController.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 05/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

//TODO: Provide the user with better feedback in case of network problems
class MovieViewController: UIViewController {
    
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    private let refreshControl = UIRefreshControl()
    
    func configure() {
        movieCollectionView.delegate = self
        movieCollectionView.dataSource = self
        flowLayout.scrollDirection = .vertical
        setupRefreshControl()        
    }
    
    func setupRefreshControl() {
        movieCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(updateCollectionView), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
    }
    
    @objc func updateCollectionView() {
        URLCache.shared.removeAllCachedResponses()
        refreshControl.endRefreshing()
        movieCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
}

extension MovieViewController: UICollectionViewDelegate { }

extension MovieViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 6 }
    func numberOfSections(in collectionView: UICollectionView) -> Int { 3 }
    
    // TODO: Make this generic and shift betweeen different categories.
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as? HeaderCollectionReusableView {
            switch indexPath.section {
            case 0:
                sectionHeader.titleLabel.text = "Thriller"
            case 1:
                sectionHeader.titleLabel.text = "Drama"
            case 2:
                sectionHeader.titleLabel.text = "Romance"
            default:
                sectionHeader.titleLabel.text = "Unknown"
            }
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCollectionViewCell
        
        switch indexPath.section {
        case 0:
            // THRILLER SECTION
            NetworkService.search(genre: .action, limit: 6) { (result) in
                do {
                    let movies = try result.get()
                    let movie = movies.results[indexPath.row]
                    cell.setTileLabel(with: movie.trackName)
                    cell.loadImage(with: movie.trackId)
                    cell.movieId = movie.trackId
                    cell.genre = Genre(rawValue: movie.primaryGenreName)
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        case 1:
            // DRAMA SECTION
            NetworkService.search(genre: .drama, limit: 6) { (result) in
                do {
                    let movies = try result.get()
                    let movie = movies.results[indexPath.row]
                    cell.setTileLabel(with: movie.trackName)
                    cell.loadImage(with: movie.trackId)
                    cell.movieId = movie.trackId
                    cell.genre = Genre(rawValue: movie.primaryGenreName)
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        case 2:
            //ROMANCE SECTION
            NetworkService.search(genre: .romance, limit: 6) { (result) in
                do {
                    let movies = try result.get()
                    let movie = movies.results[indexPath.row]
                    cell.setTileLabel(with: movie.trackName)
                    cell.loadImage(with: movie.trackId)
                    cell.movieId = movie.trackId
                    cell.genre = Genre(rawValue: movie.primaryGenreName)
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        default:
            return MovieCollectionViewCell()
        }
        
        defer {
            cell.clearImage()
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? MovieCollectionViewCell {
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movieId = cell.movieId
            detailViewController.genre = cell.genre
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetailsSeque", sender: collectionView.cellForItem(at: indexPath))
    }

}

//extension MovieViewController: UICollectionViewDelegateFlowLayout { }

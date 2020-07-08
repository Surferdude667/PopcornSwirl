//
//  FeaturedChildViewController.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 07/07/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

protocol FeaturedChilViewControllerDelegate {
    func featuredMovieSelected(id: Int)
}


class FeaturedChildViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let collectionViewLayoutManager = CollectionViewLayoutManager()
    let numberOfItems = 8
    var genre: Genre?
    var movieId: Int?
    var featuredMovies = [Movie]()
    
    var delegate: FeaturedChilViewControllerDelegate?
    
    func configure() {
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchFeaturedMovies()
        
        let fractionalViewHeight = collectionViewLayoutManager.calculateFractionalCellHeight(from: view)
        collectionView.collectionViewLayout = collectionViewLayoutManager.createCollectionViewLayout(offset: fractionalViewHeight, orientation: .horizontal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func fetchFeaturedMovies() {
        guard let genre = genre else { return }
        NetworkService.search(genre: genre, limit: 25) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                var movies = response.results
                movies.removeAll(where: { $0.trackId == self.movieId })
                let featured = Array(Set(movies)).prefix(self.numberOfItems)
                self.featuredMovies = Array(featured)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

extension FeaturedChildViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MovieCollectionViewCell
        if let id = cell.movieId {
            delegate?.featuredMovieSelected(id: id)
            fetchFeaturedMovies()
        }
    }
}

extension FeaturedChildViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { numberOfItems }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredMovieCell", for: indexPath) as! MovieCollectionViewCell
        
        if featuredMovies.count == numberOfItems {
            cell.loadImage(from: featuredMovies[indexPath.row].artworkUrl100)
            cell.movieId = featuredMovies[indexPath.row].trackId
            cell.genre = Genre(rawValue: featuredMovies[indexPath.row].primaryGenreName)
        }
        
        return cell
    }
}

//
//  FeaturedChildViewController.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 07/07/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class FeaturedChildViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let collectionViewLayoutManager = CollectionViewLayoutManager()
    let numberOfItems = 8
    var genre: Genre?
    var movieId: Int?
    var featuredMovies = [Movie]()
    
    func configure() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let fractionalViewHeight = collectionViewLayoutManager.calculateFractionalCellHeight(from: view)
        collectionView.collectionViewLayout = collectionViewLayoutManager.createCollectionViewLayout(offset: fractionalViewHeight, orientation: .horizontal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
}

extension FeaturedChildViewController: UICollectionViewDelegate { }

extension FeaturedChildViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { numberOfItems }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuredMovieCell", for: indexPath) as! MovieCollectionViewCell
        if let genre = genre {
            NetworkService.search(genre: genre, limit: 25) { (result) in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let response):
                    var movies = response.results
                    movies.removeAll(where: { $0.trackId == self.movieId })
                    let featured = Array(Set(movies)).prefix(self.numberOfItems)
                    cell.loadImage(from: featured[indexPath.row].artworkUrl100)
                }
            }
        }
        
        return cell
    }
    
}

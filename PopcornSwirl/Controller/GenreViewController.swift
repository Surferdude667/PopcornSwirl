//
//  GenreViewController.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 07/07/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class GenreViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var collectionViewLayoutManager = CollectionViewLayoutManager()
    let networkService = NetworkService()
    let numberOfItems = 48
    var genre: Genre?
    
    func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let fractionalViewHeight = collectionViewLayoutManager.calculateFractionalCellHeight(from: view)
        collectionView.collectionViewLayout = collectionViewLayoutManager.createCollectionViewLayout(offset: fractionalViewHeight, orientation: .vertical)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
}


extension GenreViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetailsSeque", sender: collectionView.cellForItem(at: indexPath))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? MovieCollectionViewCell {
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movieId = cell.movieId
            detailViewController.genre = cell.genre
        }
    }
    
}

extension GenreViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { numberOfItems }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as? HeaderCollectionReusableView {
                        
            if let genre = genre {
                let genreColor = ColorManager().provideGenreColor(genre)
                sectionHeader.gradientLine.firstColor = genreColor
                sectionHeader.genreLabel.text = genre.rawValue
            }
            
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCollectionViewCell
        if let genre = genre {
            print("Called")
            NetworkService.search(genre: genre, limit: numberOfItems) { (result) in
                switch result {
                case .success(let result):
                    let movies = result.results
                    cell.loadImage(from: movies[indexPath.row].artworkUrl100)
                    cell.setTileLabel(with: movies[indexPath.row].trackName)
                    cell.movieId = movies[indexPath.row].trackId
                    cell.genre = Genre(rawValue: movies[indexPath.row].primaryGenreName)
                case .failure(let error):
                    print(error)
                    cell.setCellToFault()
                }
            }
        }
               
        return cell
    }
    
}

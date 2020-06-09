//
//  MovieViewController.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 05/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    func configure() {
        collectionView.delegate = self
        collectionView.dataSource = self
        flowLayout.scrollDirection = .vertical
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
        DataService.search(genre: .drama, limit: 10) { (result) in
            switch result {
            case .success(let movies):
                for movie in movies.results {
                    print("Title: \(movie.trackName)")
                    print("Genre: \(movie.primaryGenreName)")
                    print("ID: \(movie.trackId)")
                    print("Release date: \(movie.releaseDate)")
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension MovieViewController: UICollectionViewDelegate { }

extension MovieViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        6
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCollectionViewCell
        
        switch indexPath.section {
        case 0:
            DataService.search(genre: .action, limit: 6) { (result) in
                do {
                    let movies = try result.get()
                    let movie = movies.results[indexPath.row]
                    cell.setTileLabel(with: movie.trackName)
                    cell.loadImage(with: movie.trackId)
                } catch {
                    print(error)
                }
            }
        case 1:
            DataService.search(genre: .drama, limit: 6) { (result) in
                do {
                    let movies = try result.get()
                    let movie = movies.results[indexPath.row]
                    cell.setTileLabel(with: movie.trackName)
                    cell.loadImage(with: movie.trackId)
                } catch {
                    print(error)
                }
            }
        case 2:
            DataService.search(genre: .romance, limit: 6) { (result) in
                do {
                    let movies = try result.get()
                    let movie = movies.results[indexPath.row]
                    cell.setTileLabel(with: movie.trackName)
                    cell.loadImage(with: movie.trackId)
                } catch {
                    print(error)
                }
            }
        default:
            return MovieCollectionViewCell()
        }
        return cell
    }
    
}

extension MovieViewController: UICollectionViewDelegateFlowLayout {
    
}

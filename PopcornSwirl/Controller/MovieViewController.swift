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
    
    let numberOfSections = 4
    let rowsInSections = 6
    
    
    
    var movies = [[Movie]]()
    
    func configure() {
        movieCollectionView.delegate = self
        movieCollectionView.dataSource = self
        flowLayout.scrollDirection = .vertical
        setupRefreshControl()
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
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
    
    func populateGenreArray(sections: Int) {
        
    }
    
    func loadMovieSections(genreSections: Int, moviesInSection: Int, completion: @escaping (Result<[[Movie]], Error>) -> Void) {
        var movieArray = [[Movie]]()
        let allGeneres = Genre.allCases
        let randomSelectedGenres = Array(Set(allGeneres)).prefix(genreSections)
        
        let genreDispatch = DispatchGroup()
        
        for genere in randomSelectedGenres {
            genreDispatch.enter()
            
            NetworkService.search(genre: genere, limit: moviesInSection) { (result) in
                switch result {
                case .success(let fetchedMovies):
                    movieArray.append(fetchedMovies.results)
                    genreDispatch.leave()
                case .failure(let error):
                    print(error)
                    genreDispatch.leave()
                }
            }
        }
        
        genreDispatch.notify(queue: .main) {
            completion(.success(movieArray))
        }
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

extension MovieViewController: UICollectionViewDelegate { }

extension MovieViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { 6 }
    func numberOfSections(in collectionView: UICollectionView) -> Int { 4 }
    
    // TODO: Make this generic and shift betweeen different categories. (Should be fairly easy...) random genre list[indexPath].section
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as? HeaderCollectionReusableView {
            
            sectionHeader.titleLabel.text = "headlines[indexPath.section]"
            
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCollectionViewCell
        let section = indexPath.section
        let row = indexPath.row
        
        loadMovieSections(genreSections: 4, moviesInSection: 6) { (result) in
            switch result {
            case .success(let movies):
                cell.setTileLabel(with: movies[section][row].trackName)
                cell.loadImage(with: movies[section][row].trackId)
                cell.movieId = movies[section][row].trackId
                cell.genre = Genre(rawValue: movies[section][row].primaryGenreName)
            case .failure(let error):
                cell.faildToLoadCell()
                print(error)
            }
        }
        
        defer { cell.clearImage() }
        return cell
    }
}

//extension MovieViewController: UICollectionViewDelegateFlowLayout { }

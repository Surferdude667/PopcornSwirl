//
//  MovieViewController.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 05/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit
import NotificationBannerSwift

//TODO: Provide the user with better feedback in case of network problems
class MovieViewController: UIViewController {
    
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    private let refreshControl = UIRefreshControl()
    let numberOfSections = 3
    let rowsInSections = 6
    var genres = [Genre]()
    var noConnectionBanner: StatusBarNotificationBanner?
    var backOnlineBanner: StatusBarNotificationBanner?
    
    func configure() {
        NotificationCenter.default.addObserver(self, selector: #selector(connectionRestored(notification:)), name: .connectionRestored, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectionLost(notification:)), name: .connectionLost, object: nil)
        
        movieCollectionView.delegate = self
        movieCollectionView.dataSource = self
        flowLayout.scrollDirection = .vertical
        setupRefreshControl()
        populateGenreArray()
    }
    
    @objc func connectionRestored(notification: NSNotification) {
        movieCollectionView.reloadData()
        print("CONNECTION RESTORED")
    }
    
    @objc func connectionLost(notification: NSNotification) {
        print("CONNECTION Lost")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    
    func setupRefreshControl() {
        movieCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(updateCollectionView), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
    }
    
    @objc func updateCollectionView() {
        URLCache.shared.removeAllCachedResponses()
        genres.removeAll()
        populateGenreArray()
        refreshControl.endRefreshing()
        movieCollectionView.reloadData()
    }
    
    func populateGenreArray() {
        let allGeneres = Genre.allCases
        let randomSelectedGenres = Array(Set(allGeneres)).prefix(numberOfSections)
        genres = Array(randomSelectedGenres)
    }
    
    func loadMovieSections(completion: @escaping ([[Movie]]) -> Void) {
        var movieArray = [[Movie]]()
        let genreDispatch = DispatchGroup()
        
        for genre in genres {
            genreDispatch.enter()
            NetworkService.search(genre: genre, limit: rowsInSections) { (result) in
                switch result {
                case .success(let fetchedMovies):
                    movieArray.append(fetchedMovies.results)
                    genreDispatch.leave()
                case .failure(let error):
                    print(error)
                    let failedMovie = Movie(trackId: 0,
                                            trackName: "NaN",
                                            primaryGenreName: "NaN",
                                            releaseDate: "NaN",
                                            artworkUrl100: "NaN",
                                            longDescription: "NaN",
                                            trackViewUrl: "NaN")
                    let emptyMovie = [Movie](repeating: failedMovie, count: self.rowsInSections)
                    movieArray.append(emptyMovie)
                    genreDispatch.leave()
                }
            }
        }
        
        genreDispatch.notify(queue: .main) {
            completion(movieArray)
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { rowsInSections }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { numberOfSections }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as? HeaderCollectionReusableView {
            sectionHeader.titleLabel.text = genres[indexPath.section].rawValue
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCollectionViewCell
        let section = indexPath.section
        let row = indexPath.row
        
        loadMovieSections() { (movies) in
            if movies[section][row].trackId == 0 {
                cell.faildToLoadCell()
                return
            }
            cell.clearImage()
            cell.setTileLabel(with: movies[section][row].trackName)
            cell.movieId = movies[section][row].trackId
            cell.loadImage(from: movies[section][row].artworkUrl100)
            cell.genre = Genre(rawValue: movies[section][row].primaryGenreName)
        }
        
        return cell
    }
}

//extension MovieViewController: UICollectionViewDelegateFlowLayout { }

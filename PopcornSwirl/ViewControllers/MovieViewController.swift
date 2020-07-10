//
//  MovieViewController.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 05/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class MovieViewController: UIViewController {
    
    @IBOutlet weak var movieCollectionView: UICollectionView!

    private let refreshControl = UIRefreshControl()
    var collectionViewLayoutManager = CollectionViewLayoutManager()
    var defaultSections = 0
    var defaultItems = 0
    
    let numberOfSections = 4
    let numberOfItems = 6
    
    var genres = [Genre]()
    var movies = [[Movie]]()
    
    func configure() {
        NotificationCenter.default.addObserver(self, selector: #selector(connectionRestored(notification:)), name: .connectionRestored, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectionLost(notification:)), name: .connectionLost, object: nil)
        
        overrideUserInterfaceStyle = .dark
        movieCollectionView.delegate = self
        movieCollectionView.dataSource = self
        setupRefreshControl()
        
        let fractionalViewHeight = collectionViewLayoutManager.calculateFractionalCellHeight(from: view)
        movieCollectionView.collectionViewLayout = collectionViewLayoutManager.createCollectionViewLayout(offset: fractionalViewHeight, orientation: .horizontal)
        
        populateCollectionView()
    }
    
    @objc func connectionRestored(notification: NSNotification) {
        movieCollectionView.reloadData()
        print("CONNECTION RESTORED")
    }
    
    @objc func connectionLost(notification: NSNotification) {
        print("CONNECTION LOST")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func populateCollectionView() {
        populateGenreArray(numberOfSections)
        
        loadMovieSections(items: numberOfItems) { (result) in
            self.movies = result
            self.defaultSections = self.numberOfSections
            self.defaultItems = self.numberOfItems
            self.movieCollectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //movieCollectionView.reloadData()
    }
    
    
    func setupRefreshControl() {
        movieCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(updateCollectionView), for: .valueChanged)
        refreshControl.tintColor = .lightGray
    }
    
    @objc func updateCollectionView() {
        populateGenreArray(numberOfSections)
        self.refreshControl.endRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.populateCollectionView()
        }
    }
    
    func populateGenreArray(_ sections: Int) {
        genres.removeAll()
        let allGeneres = Genre.allCases
        let randomSelectedGenres = Array(Set(allGeneres)).prefix(sections)
        genres = Array(randomSelectedGenres)
    }
    
    func loadMovieSections(items: Int, completion: @escaping ([[Movie]]) -> Void) {
        var movieArray = [[Movie]]()
        let genreDispatch = DispatchGroup()
        
        for genre in genres {
            genreDispatch.enter()
            NetworkService.search(genre: genre, limit: items) { (result) in
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
                                            trackViewUrl: "NaN",
                                            trackPrice: 0.0)
                    let emptyMovie = [Movie](repeating: failedMovie, count: items)
                    movieArray.append(emptyMovie)
                    genreDispatch.leave()
                }
            }
        }
        
        genreDispatch.notify(queue: .main) {
            completion(movieArray)
        }
    }
}

extension MovieViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetailsSeque", sender: collectionView.cellForItem(at: indexPath))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? MovieCollectionViewCell {
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movieId = cell.movieId
            detailViewController.genre = cell.genre
        }
        
        if let genre = sender as? Genre {
            let genreViewController = segue.destination as! GenreViewController
            genreViewController.genre = genre
        }
        
    }
}

extension MovieViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { defaultItems }
    func numberOfSections(in collectionView: UICollectionView) -> Int { defaultSections }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as? HeaderCollectionReusableView {
            let movie = movies[indexPath.section][0]
            
            if let genre = Genre(rawValue: movie.primaryGenreName) {
                let genreColor = ColorManager().provideGenreColor(genre)
                sectionHeader.gradientLine.firstColor = genreColor
                sectionHeader.showAllButton.setTitleColor(genreColor, for: .normal)
                sectionHeader.genreLabel.text = genre.rawValue
                sectionHeader.genre = genre
            }
            
            sectionHeader.delegate = self
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCollectionViewCell
        let section = indexPath.section
        let row = indexPath.row
        
        if movies[section][row].trackId == 0 {
            cell.setCellToFault()
            return cell
        }
        
        cell.setTileLabel(with: movies[section][row].trackName)
        cell.movieId = movies[section][row].trackId
        cell.genre = Genre(rawValue: movies[section][row].primaryGenreName)
        cell.loadImage(from: movies[section][row].artworkUrl100)
        
        return cell
    }
}

extension MovieViewController: HeaderCollectionReusableViewDelegate {
    func showAllTapped(genre: Genre) {
        performSegue(withIdentifier: "toGenreSeque", sender: genre)
    }
}

//
//  DetailViewController.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 05/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

// TODO: Maybe implement the "Difused view for the background"
class DetailViewController: UIViewController {
    
    var movieId: Int?
    var genre: Genre?
    var buyURL: URL?
    var movieWatched: Bool?
    var movieBookmarked: Bool?
    var movieAdditionsExists = false
    let coreDataManager = CoreDataManager()
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var longDescriptionLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var watchedButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    // TODO: Implement array of spinning loaders as well. Maybe create your own spinner...? Could look sooo unified.
    @IBOutlet var relatedImageViews: [UIImageView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        clearUI()
        fetchMovieData()
        loadMovieAdditions()
        fetchFeaturedMovies()
    }
    
    func clearUI() {
        // TODO: Start spinning, empty images, empty texts.
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
                let featuredMovies = Array(Set(movies)).prefix(4)
                
                for featured in 0..<featuredMovies.count {
                    NetworkService.fetchImage(from: featuredMovies[featured].artworkUrl100, size: 200, completion: { (result) in
                        do {
                            let imageData = try result.get()
                            DispatchQueue.main.async {
                                self.relatedImageViews[featured].image = UIImage(data: imageData)
                                self.relatedImageViews[featured].tag = featuredMovies[featured].trackId
                            }
                        } catch {
                            print("Related Image coud not be loaded...")
                        }
                    })
                }
            }
        }
    }
    
    // MARK: - ADD NOTE
    func showEditNoteAlert() {
        let alertController = UIAlertController(title: "Personal note", message: "Add something to remember", preferredStyle: .alert)
        alertController.addTextField()
        alertController.textFields![0].returnKeyType = .done
        
        if notesTextView.text != "Add a personal note..." {
            alertController.textFields![0].text = notesTextView.text
        }
        
        let addNoteAction = UIAlertAction(title: "Save", style: .default) { [unowned alertController] _ in
            let entry = alertController.textFields![0]
            
            if (entry.text != self.notesTextView.text) {
                guard let movieId = self.movieId else { return }
                
                if entry.text?.trimmingCharacters(in: .whitespaces) == "" {
                    self.notesTextView.text = "Add a personal note..."
                    _ = self.coreDataManager.setNoteToNill(id: movieId)
                } else {
                    self.notesTextView.text = entry.text
                    do { _ = try self.coreDataManager.updateMovieAddition(id: movieId, note: entry.text).get()
                    } catch let error {
                        let dataError = error as! CoreDataError
                        switch dataError {
                        case .additionNotFound:
                            try? self.coreDataManager.addMovieAddition(id: movieId, note: entry.text)
                            self.loadMovieAdditions()
                        default:
                            print(dataError)
                        }
                    }
                }
            }
        }
        alertController.addAction(addNoteAction)
        present(alertController, animated: true)
    }
    
    // MARK: - REQUEST API FETCHING
    func fetchMovieData() {
        guard let movieId = movieId else { return }
        NetworkService.lookup(id: movieId) { (result) in
            do {
                let movie = try result.get().results.first
                if let artworkURL = movie?.artworkUrl100 {
                    NetworkService.fetchImage(from: artworkURL, size: 500) { (result) in
                        switch result {
                        case .success(let imageData):
                            DispatchQueue.main.async {
                                self.coverImageView.image = UIImage(data: imageData)
                                self.movieTitleLabel.text = movie?.trackName
                                self.longDescriptionLabel.text = movie?.longDescription
                                if let urlString = movie?.trackViewUrl { self.buyURL = URL(string: urlString) }
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            } catch let error {
                print(error)
            }
        }
    }
    
    //MARK: - MOVIE ADDITIONS
    func loadMovieAdditions() {
        guard let movieId = movieId else { return }
        let additions = coreDataManager.fetchSavedMovieAddition(id: movieId)
        switch additions {
        case .success(let movieAddition):
            updateMovieAdditions(additions: movieAddition)
            movieAdditionsExists = true
        case .failure(.additionNotFound):
            movieAdditionsExists = false
            resetMovieAdditions()
        default: print("Unknown error")
        }
    }
    
    // TODO: This will be deprecated and combined with the clearUI() function.
    func resetMovieAdditions() {
        watchedButton.tintColor = .red
        bookmarkButton.tintColor = .red
        notesTextView.text = "Add a personal note..."
    }
    
    func updateMovieAdditions(additions: SavedMovieAddition) {
        // UPDATE NOTES ADDITIONS
        if additions.note != nil {
            notesTextView.text = additions.note
        }
        // UPDATE WATCHED ADDITIONS
        if additions.watched?.isWatched == true {
            watchedButton.tintColor = .green
            movieWatched = true
        } else {
            watchedButton.tintColor = .red
            movieWatched = false
        }
        // UPDATE BOOKMARKED ADDITIONS
        if additions.bookmarked?.isBookmarked == true {
            bookmarkButton.tintColor = .green
            movieBookmarked = true
        } else {
            bookmarkButton.tintColor = .red
            movieBookmarked = false
        }
    }
    
    
    // TODO: Need to refactor update function
    // In this viewcontroller fet addition object and use that internaly. Then send it to update function. (Will prevent all this stupid checking twice...
    // MARK: - WATCHED BUTTON
    @IBAction func watchedButtonTapped(_ sender: Any) {
        guard let movieId = movieId else { return }
        if movieAdditionsExists == true {
            // Update watched additions
            if movieWatched == true {
                do {
                    let updatedAdditions = try coreDataManager.updateMovieAddition(id: movieId, watched: false).get()
                    updateMovieAdditions(additions: updatedAdditions)
                } catch { print("error: \(error)") }
            } else if movieWatched == false {
                do {
                    let updatedAdditions = try coreDataManager.updateMovieAddition(id: movieId, watched: true).get()
                    updateMovieAdditions(additions: updatedAdditions)
                } catch { print("error: \(error)") }
            }
            // Add new movie additions
        } else if movieAdditionsExists == false {
            do {
                try coreDataManager.addMovieAddition(id: movieId, watched: true)
                loadMovieAdditions()
            } catch { print("error: \(error)") }
        }
    }
    
    // MARK: - BOOKMARK BUTTON
    @IBAction func bookmarkButtonTapped(_ sender: Any) {
        guard let movieId = movieId else { return }
        if movieAdditionsExists == true {
            // Update bookmarked additions
            if movieBookmarked == true {
                do {
                    let updatedAdditions = try coreDataManager.updateMovieAddition(id: movieId, bookmarked: false).get()
                    updateMovieAdditions(additions: updatedAdditions)
                } catch { print(error) }
            } else if movieBookmarked == false {
                do {
                    let updatedAdditions = try coreDataManager.updateMovieAddition(id: movieId, bookmarked: true).get()
                    updateMovieAdditions(additions: updatedAdditions)
                } catch { print(error) }
            }
            // Add new movie additions
        } else if movieAdditionsExists == false {
            do {
                try coreDataManager.addMovieAddition(id: movieId, bookmarked: true)
                loadMovieAdditions()
            } catch { print(error) }
        }
    }
    
    // MARK: - NOTE TAPPED
    @IBAction func noteTapped(_ sender: Any) {
        showEditNoteAlert()
    }
    
    // MARK: - RELATED MOVIE TAPPED
    @IBAction func relatedMovieTapped(_ sender: UITapGestureRecognizer) {
        movieId = sender.view?.tag
        configure()
    }
    
    @IBAction func buyButton(_ sender: Any) {
        guard let url = buyURL else { return }
        UIApplication.shared.open(url)
    }
}

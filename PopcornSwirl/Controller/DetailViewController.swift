//
//  DetailViewController.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 05/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var movieId: Int?
    var genre: Genre?
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
    
    // TODO: Implement array of spinning loaders as well.
    @IBOutlet var relatedImageViews: [UIImageView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        loadData()
        loadMovieAdditions()
        fetchRelatedMovies()
    }
    
    
    func fetchRelatedMovies() {
        guard let genre = genre else { return }
        NetworkService.search(genre: genre, limit: 25) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                let movies = response.results
                let featuredMovies = Array(Set(movies)).prefix(4)
                // TODO: Prevent the current movie from being displayed.
                for featured in 0..<featuredMovies.count {
                    NetworkService.fetchImage(from: featuredMovies[featured].artworkUrl100, completion: { (result) in
                        do {
                            let imageData = try result.get()
                            DispatchQueue.main.async {
                                 self.relatedImageViews[featured].image = UIImage(data: imageData)
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
        let alertController = UIAlertController(title: "Add note", message: "Write a personal note about this movie", preferredStyle: .alert)
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
                    _ = self.coreDataManager.updateMovieAddition(id: movieId, note: entry.text)
                }
            }
        }
        alertController.addAction(addNoteAction)
        present(alertController, animated: true)
    }
    
    // MARK: - REQUEST API FETCHING
    func loadData() {
        guard let movieId = movieId else { return }
        NetworkService.lookup(id: movieId) { (result) in
            do {
                let movie = try result.get().results.first
                if let rawArtowrkURL = movie?.artworkUrl100 {
                    let artworkURL = rawArtowrkURL.replacingOccurrences(of: "100x100bb", with: "500x500bb")
                    NetworkService.fetchImage(from: artworkURL) { (result) in
                        switch result {
                        case .success(let imageData):
                            DispatchQueue.main.async {
                                self.coverImageView.image = UIImage(data: imageData)
                                self.movieTitleLabel.text = movie?.trackName
                                self.longDescriptionLabel.text = movie?.longDescription
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
            print("Addition not found")
        default: print("Unknown error")
        }
    }
    
    // TODO: Default state in Storyboard should be "Unmarked".
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
    
    // MARK: - WATCHED BUTTON
    @IBAction func watchedButtonTapped(_ sender: Any) {
        guard let movieId = movieId else { return }
        if movieAdditionsExists == true {
            // Update watched additions
            if movieWatched == true {
                do {
                    let updatedAdditions = try coreDataManager.updateMovieAddition(id: movieId, watched: false).get()
                    updateMovieAdditions(additions: updatedAdditions)
                } catch { print(error) }
            } else if movieWatched == false {
                do {
                    let updatedAdditions = try coreDataManager.updateMovieAddition(id: movieId, watched: true).get()
                    updateMovieAdditions(additions: updatedAdditions)
                } catch { print(error) }
            }
            // Add new movie additions
        } else if movieAdditionsExists == false {
            do {
                try coreDataManager.addMovieAddition(id: movieId, watched: true)
                loadMovieAdditions()
            } catch { print(error) }
        }
    }
    
    // MARK: - BOOKMARK BUTTON
    @IBAction func bookmarkButtonTapped(_ sender: Any) {
        guard let movieId = movieId else { return }
        if movieAdditionsExists == true {
            // Update watched additions
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
}

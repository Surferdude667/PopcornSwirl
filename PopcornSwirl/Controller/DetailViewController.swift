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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        loadData()
        loadMovieAdditions()
    }
    
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
    // TODO: Figure out if these two button functions can turn into one.
    // MARK:- Watched Button
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
    
    // MARK:- Bookmark Button
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
    
}

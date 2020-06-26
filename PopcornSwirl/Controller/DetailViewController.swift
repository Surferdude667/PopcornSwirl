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
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var longDescriptionLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var watchedButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    // TODO: Implement array of spinning loaders as well. Maybe create your own spinner...? Could look sooo unified.
    @IBOutlet var relatedImageViews: [UIImageView]!
    
    let coreDataManager = CoreDataManager()
    var delegate: DetailViewControllerDelegate?
    let notePlaceholder = "Add a personal note..."
    var movieAdditions: SavedMovieAddition?
    var movieId: Int?
    var genre: Genre?
    var sentFrom: IndexPath?
    var buyURL: URL?
    
    // Bookmark
    var newBookmarkAdditions = [SavedMovieAddition?]()
    var removedBookmarkAdditions = [IndexPath]()
    var originalBookmarkedValue: Bool?
    
    // Watched
    var newWatchedAdditions = [SavedMovieAddition?]()
    var removedWatchedAdditions = [IndexPath]()
    var originalWatchedValue: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        presentationController?.delegate = self
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
                        } catch { print("Related Image coud not be loaded...") }
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
        if notesTextView.text != notePlaceholder { alertController.textFields![0].text = notesTextView.text }
        
        let addNoteAction = UIAlertAction(title: "Save", style: .default) { [unowned alertController] _ in
            let entry = alertController.textFields![0]
            if entry.text != self.notesTextView.text {
                guard let movieId = self.movieId else { return }
                
                // Addition don't exists, create new one with input and return.
                guard let additions = self.movieAdditions else {
                    if entry.text?.trimmingCharacters(in: .whitespaces) != "" {
                        do {
                            try self.coreDataManager.addMovieAddition(id: movieId, note: entry.text)
                            self.loadMovieAdditions()
                        } catch { print(error) }
                    }
                    return
                }
                
                // Addition does exist, check if empty else update with input.
                if entry.text?.trimmingCharacters(in: .whitespaces) == "" { additions.note = nil }
                else { additions.note = entry.text }
                
                do { try self.coreDataManager.context.save() }
                catch { print(error) }
                self.updateMovieAdditionsUI()
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
    func loadMovieAdditions(cacheBookmarks: Bool? = false, cacheWatched: Bool? = false) {
        guard let movieId = movieId else { return }
        do {
            movieAdditions = try coreDataManager.fetchSavedMovieAddition(id: movieId).get()
            
            // Cache bookmarks for use in delegate
            if cacheBookmarks == true { newBookmarkAdditions.append(movieAdditions) }
            else { originalBookmarkedValue = movieAdditions?.bookmarked?.isBookmarked }
            
            // Cache watched for use in delegate
            if cacheWatched == true { newWatchedAdditions.append(movieAdditions) }
            else { originalWatchedValue = movieAdditions?.watched?.isWatched }
            
        } catch {
            movieAdditions = nil
            originalBookmarkedValue = nil
            originalWatchedValue = nil
        }
        updateMovieAdditionsUI()
    }
    
    func updateMovieAdditionsUI() {
        guard let additions = movieAdditions else {
            watchedButton.tintColor = .red
            bookmarkButton.tintColor = .red
            notesTextView.text = notePlaceholder
            return
        }
        
        if additions.note != nil { notesTextView.text = additions.note }
        else { notesTextView.text = notePlaceholder }
        
        if additions.watched?.isWatched == true { watchedButton.tintColor = .green }
        else { watchedButton.tintColor = .red }
        
        if additions.bookmarked?.isBookmarked == true { bookmarkButton.tintColor = .green }
        else { bookmarkButton.tintColor = .red }
    }
    
    func toggleAdditons(type: AdditionType) {
        guard let movieId = movieId else { return }
        if let additions = movieAdditions {
            if type == .watched {
                if additions.watched?.isWatched == true {
                    movieAdditions?.watched?.isWatched = false
                    movieAdditions?.watched?.date = nil
                } else if additions.watched?.isWatched == false || additions.watched?.isWatched == nil {
                    movieAdditions?.watched?.isWatched = true
                    movieAdditions?.watched?.date = Date()
                    newWatchedAdditions.append(movieAdditions)
                }
            }
            if type == .bookmarked {
                if additions.bookmarked?.isBookmarked == true {
                    movieAdditions?.bookmarked?.isBookmarked = false
                    movieAdditions?.bookmarked?.date = nil
                } else if additions.bookmarked?.isBookmarked == false || additions.bookmarked?.isBookmarked == nil {
                    movieAdditions?.bookmarked?.isBookmarked = true
                    movieAdditions?.bookmarked?.date = Date()
                    newBookmarkAdditions.append(movieAdditions)
                }
            }
            do { try coreDataManager.context.save() }
            catch { print(error) }
            updateMovieAdditionsUI()
        } else {
            if type == .watched {
                try? coreDataManager.addMovieAddition(id: movieId, watched: true)
                loadMovieAdditions(cacheWatched: true)
            }
            if type == .bookmarked {
                try? coreDataManager.addMovieAddition(id: movieId, bookmarked: true)
                loadMovieAdditions(cacheBookmarks: true)
            }
        }
    }
    
    @IBAction func watchedButtonTapped(_ sender: Any) { toggleAdditons(type: .watched) }
    @IBAction func bookmarkButtonTapped(_ sender: Any) { toggleAdditons(type: .bookmarked) }
    @IBAction func noteTapped(_ sender: Any) { showEditNoteAlert() }
    @IBAction func buyButton(_ sender: Any) { if let url = buyURL {UIApplication.shared.open(url)} }
    @IBAction func relatedMovieTapped(_ sender: UITapGestureRecognizer) {
        movieId = sender.view?.tag
        configure()
        sentFrom = nil
    }
}

extension DetailViewController: UIAdaptivePresentationControllerDelegate {
    
    // MARK:- DetailViewControllerDelegate calls
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard let movieAdditions = movieAdditions else { return }
        
        // Remove watched addition
        if movieAdditions.watched?.isWatched != originalWatchedValue {
            if newWatchedAdditions.count == 0 {
                delegate?.watchedAdditionsRemoved(at: sentFrom)
            }
        }
        
        // Add new watched addition
        if newWatchedAdditions.count > 0 {
            if movieAdditions.watched?.isWatched != originalWatchedValue {
                delegate?.watchedAdditionsAdded(additions: newWatchedAdditions)
                newWatchedAdditions.removeAll()
            }
        }
        
        // Remove bookmark addition
        if movieAdditions.bookmarked?.isBookmarked != originalBookmarkedValue {
            if newBookmarkAdditions.count == 0 {
                delegate?.bookmarkAdditionsRemoved(at: sentFrom)
            }
        }
        
        // Add new bookmark addition
        if newBookmarkAdditions.count > 0 {
            if movieAdditions.bookmarked?.isBookmarked != originalBookmarkedValue {
                delegate?.bookmarkAdditionsAdded(additions: newBookmarkAdditions)
                newBookmarkAdditions.removeAll()
            }
        }
    }
    
}

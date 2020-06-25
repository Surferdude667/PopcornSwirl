//
//  DetailViewController.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 05/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit
import NotificationBannerSwift

protocol DetailViewControllerDelegate {
    func watchedAdditionsChanged(_ additions: SavedMovieAddition, destinationIndexPath: IndexPath?)
    
    func bookmarkAdditionsRemoved(at indexPath: IndexPath?)
    func bookmarkAdditionsAdded(additions: [SavedMovieAddition?])
}

extension DetailViewControllerDelegate {
    func watchedAdditionsChanged(_ additions: SavedMovieAddition, destinationIndexPath: IndexPath?) { }
    func bookmarkAdditionsChanged(_ newAdditions: [SavedMovieAddition?], destinationIndexPath: IndexPath?) { }
}

// TODO: Maybe implement the "Difused view for the background"
class DetailViewController: UIViewController {
    
    var movieId: Int?
    var genre: Genre?
    var sentFrom: IndexPath?
    
    var buyURL: URL?
    var movieAdditions: SavedMovieAddition?
    let coreDataManager = CoreDataManager()
    let notePlaceholder = "Add a personal note..."
    
    var originalWatchedValue: Bool?
    var originalBookmarkedValue: Bool?
    var forceUpdateBookmarkCollectionView = false
    var forceUpdateWatchedCollectionView = false
    
    var newBookmarkAdditions = [SavedMovieAddition?]()
    var removedBookmarkAdditions = [IndexPath]()
    
    var delegate: DetailViewControllerDelegate?
    
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
        presentationController?.delegate = self
        forceUpdateBookmarkCollectionView = false
        forceUpdateWatchedCollectionView = false

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
                
                // Addition does exist, update with input.
                if entry.text?.trimmingCharacters(in: .whitespaces) == "" {
                    additions.note = nil
                } else {
                    additions.note = entry.text
                }
                
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
    func loadMovieAdditions(cashBookmarks: Bool? = false) {
        guard let movieId = movieId else { return }
        do {
            movieAdditions = try coreDataManager.fetchSavedMovieAddition(id: movieId).get()
            originalWatchedValue = movieAdditions?.watched?.isWatched
            
            
            if cashBookmarks == true {
                print("Appending \(movieAdditions?.movieID)")
                newBookmarkAdditions.append(movieAdditions)
            } else {
                print("Changing...")
                originalBookmarkedValue = movieAdditions?.bookmarked?.isBookmarked
            }
            
        }
        catch {
            movieAdditions = nil
                    originalBookmarkedValue = nil
            //        originalWatchedValue = nil
            
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
                }
            }
            if type == .bookmarked {
                if additions.bookmarked?.isBookmarked == true {
                    movieAdditions?.bookmarked?.isBookmarked = false
                    movieAdditions?.bookmarked?.date = nil
                } else if additions.bookmarked?.isBookmarked == false || additions.bookmarked?.isBookmarked == nil {
                    movieAdditions?.bookmarked?.isBookmarked = true
                    movieAdditions?.bookmarked?.date = Date()
                    
                    // MARK: REMEMBER
                    newBookmarkAdditions.append(movieAdditions)
                
                }
            }
            do { try coreDataManager.context.save() }
            catch { print(error) }
            updateMovieAdditionsUI()
        } else {
            if type == .watched {
                try? coreDataManager.addMovieAddition(id: movieId, watched: true)
                forceUpdateWatchedCollectionView = true
                loadMovieAdditions()
            }
            if type == .bookmarked {
                try? coreDataManager.addMovieAddition(id: movieId, bookmarked: true)
                forceUpdateBookmarkCollectionView = true
                loadMovieAdditions(cashBookmarks: true)
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
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard let movieAdditions = movieAdditions else { return }
        
        if movieAdditions.watched?.isWatched != originalWatchedValue {
            delegate?.watchedAdditionsChanged(movieAdditions, destinationIndexPath: sentFrom)
        } else if forceUpdateWatchedCollectionView {
            delegate?.watchedAdditionsChanged(movieAdditions, destinationIndexPath: nil)
        }
        
        // NEW NEW NEW
        if movieAdditions.bookmarked?.isBookmarked != originalBookmarkedValue {
            if newBookmarkAdditions.count == 0 {
                print("Remove called")
                delegate?.bookmarkAdditionsRemoved(at: sentFrom)
            }
        }
        
        if newBookmarkAdditions.count > 0 {
            if movieAdditions.bookmarked?.isBookmarked != originalBookmarkedValue {
                print("Add called")
                delegate?.bookmarkAdditionsAdded(additions: newBookmarkAdditions)
                newBookmarkAdditions.removeAll()
            }
            
        }
        // NEW NEW NEW
        
        
        
//        if movieAdditions.bookmarked?.isBookmarked != originalBookmarkedValue {
//            delegate?.bookmarkAdditionsChanged(movieAdditions, destinationIndexPath: sentFrom)
//        } else if forceUpdateBookmarkCollectionView {
//            delegate?.bookmarkAdditionsChanged(movieAdditions, destinationIndexPath: nil)
//        }
        
        // INSERT NEW ADDITIONS

        // Calles delegete
        // Values are not the same
        // Indexpath exists
        
//        if movieAdditions.bookmarked?.isBookmarked != originalBookmarkedValue {
//            if sentFrom != nil {
//                delegate?.bookmarkAdditionsChanged(newBookmarkAdditions, destinationIndexPath: sentFrom)
//            } else if newBookmarkAdditions.count > 0 {
//                delegate?.bookmarkAdditionsChanged(newBookmarkAdditions, destinationIndexPath: nil)
//                newBookmarkAdditions.removeAll()
//            }
            
            
        //}
        
        
        
        
//
//        if newBookmarkAdditions.count > 0 {
//
//        } else {
//            print("WHEY THE FUCK???")
//
//        }
        

        
        
        
//        if movieAdditions.bookmarked?.isBookmarked != originalBookmarkedValue {
//            print("A")
//            delegate?.bookmarkAdditionsChanged(removedBookmarkAdditions, destinationIndexPath: sentFrom)
//        } else if newBookmarkAdditions.count < 0 {
//            print("B: \(newBookmarkAdditions)")
//            delegate?.bookmarkAdditionsChanged(newBookmarkAdditions, destinationIndexPath: nil)
//        }
        
    }
}

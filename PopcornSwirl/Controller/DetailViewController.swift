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
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var longDescriptionLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var watchedButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    func configure() {
        loadData()
    }
    
    func loadData() {
        if let id = movieId {
            NetworkService.lookup(id: id) { (result) in
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    @IBAction func watchedButtonTapped(_ sender: Any) {
        let result = CoreDataManager().checkExistanceOfMovieAddition(id: movieId!)
        
        switch result {
        case .success(let movieAddition):
            print("ID: \(movieAddition.movieID)")
            print("Note: \(movieAddition.note)")
            print("Watched: \(movieAddition.watched?.isWatched)")
            print("Date watched: \(movieAddition.watched?.date)")
            print("Bookmarked: \(movieAddition.bookmarked?.isBookmarked)")
            print("Date bookmarked: \(movieAddition.bookmarked?.date)")
        case .failure(.additionNotFound):
            print("Addition not found")
        default:
            print("Unknown error")
        }
    }
    
    @IBAction func bookmarkButtonTapped(_ sender: Any) {
        CoreDataManager().addMovieAddition(id: movieId!, note: "Custom Note", watched: true)
    }
    
}

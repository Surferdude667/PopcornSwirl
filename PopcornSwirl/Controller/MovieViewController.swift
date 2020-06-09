//
//  MovieViewController.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 05/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController {
    
    @IBOutlet weak var testImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        DataService.lookup(id: 774084884) { (result) in
            switch result {
            case .success(let movies):
                if let movie = movies.results.first {
                    print("MOVIE: \(movie.trackName)")
                    let imageURL = movie.artworkUrl100.replacingOccurrences(of: "100x100bb", with: "300x300bb")
                    print("Image loading...")
                    DataService.fetchImage(from: imageURL) { (result) in
                        
                        do {
                            let imageData = try result.get()
                            DispatchQueue.main.async {
                                print("IMAGE LOADING COMPLETE...")
                                self.testImageView.image = UIImage(data: imageData)
                            }
                        } catch {
                            print("Failed to load image: \(error)")
                        }
                    }
                    
                }
            case .failure(let error):
                print(error)
            }
        }
        
        
    }
    
}

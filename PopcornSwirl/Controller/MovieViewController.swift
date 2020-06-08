//
//  MovieViewController.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 05/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class MovieViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataService.shared.search(genre: .drama, limit: 10) { (result) in
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
        
        DataService.shared.lookup(id: 1498667424) { (result) in
            switch result {
            case .success(let movies):
                if let movie = movies.results.first {
                    print("MOVIE: \(movie.trackName)")
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
}

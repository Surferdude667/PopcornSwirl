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
        
        
        DataService.shared.fetch { (result) in
            switch result {
                case .success(let movies):
                    for movie in movies.results {
                        print("Artist: \(movie.artistName)")
                        print("Genre: \(movie.primaryGenreName)")
                }
                
                
                case .failure(let error):
                    print(error)
            }
        }
        
        
    }
    
}

//
//  MovieCollectionViewCell.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 09/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "movieCell"
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var movieId: Int?
    
    func loadImage(with id: Int) {
        DataService.lookup(id: id) { (result) in
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
                                self.coverImageView.image = UIImage(data: imageData)
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
    
    func setTileLabel(with text: String) {
        DispatchQueue.main.async {
            self.titleLabel.text = text
        }
    }
    
}

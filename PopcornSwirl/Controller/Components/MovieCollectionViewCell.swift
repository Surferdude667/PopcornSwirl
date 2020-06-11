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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var movieId: Int?
    
    func clearImage() {
        DispatchQueue.main.async {
            self.coverImageView.image = nil
            self.coverImageView.alpha = 0.0
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
    
    func loadImage(with id: Int) {
        DataService.lookup(id: id) { (result) in
            switch result {
            case .success(let movies):
                if let movie = movies.results.first {
                    let imageURL = movie.artworkUrl100.replacingOccurrences(of: "100x100bb", with: "300x300bb")
                    DataService.fetchImage(from: imageURL) { (result) in
                        do {
                            let imageData = try result.get()
                            DispatchQueue.main.async {
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.isHidden = true
                                self.coverImageView.image = UIImage(data: imageData)
                                UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                                    self.coverImageView.alpha = 1.0
                                })
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

//
//  MovieCollectionViewCell.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 09/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var movieId: Int?
    var genre: Genre?
    var imageURL: URL?
    
    
    func clearImage() {
        DispatchQueue.main.async {
            self.coverImageView.image = nil
            self.coverImageView.alpha = 0.0
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
    
    func loadImage(from urlString: String) {
        NetworkService.fetchImage(from: urlString, size: 300) { (result) in
            do {
                let imageData = try result.get()
                print("Image Loaded!")
                DispatchQueue.main.async {
                    print("Dispatch block invoked")
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.coverImageView.image = UIImage(data: imageData)
                    if self.coverImageView.image != UIImage(data: imageData) {
                    UIView.animate(withDuration: 0.4, delay: 0, options: .curveLinear, animations: {
                        self.coverImageView.alpha = 1.0
                    })
                    }
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
    
    func setTileLabel(with text: String) {
        DispatchQueue.main.async {
            self.titleLabel.text = text
        }
    }
    
    // Set failed image instead.
    func faildToLoadCell() {
        titleLabel.text = "Faild..."
        coverImageView.backgroundColor = .red
    }
    
}

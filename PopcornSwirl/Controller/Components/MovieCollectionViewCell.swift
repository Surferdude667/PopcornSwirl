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
    var imageURLString: String?
    
    // TEST
    var onReuse: () -> Void = {}
    var indexPath: IndexPath?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        URLSession.shared.getAllTasks { (sessions) in
            //print(sessions.first?.currentRequest?.description)
        }
        onReuse()
        clearImage()
    }
    
    func clearImage() {
        DispatchQueue.main.async {
            //print("Image cleard \(self.movieId)")
            self.coverImageView.image = nil
            //self.coverImageView.alpha = 0.0
            self.titleLabel.text = "nil"
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            //self.movieId = nil
            //self.genre = nil
            self.imageURLString = nil
        }
    }
    
    func loadImage(from urlString: String) {
        NetworkService.fetchImage(from: imageURLString!, size: 300) { (result) in
            do {
                let imageData = try result.get()
                DispatchQueue.main.async {
                    print("URL at \(self.indexPath): \(urlString)")
                    self.coverImageView.image = nil
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = false
                    self.coverImageView.image = UIImage(data: imageData)
                    
//                    UIView.animate(withDuration: 0.4, delay: 0, options: .curveLinear, animations: {
//                        self.coverImageView.alpha = 1.0
//                    })
                    
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

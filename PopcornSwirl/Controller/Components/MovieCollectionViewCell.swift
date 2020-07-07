//
//  MovieCollectionViewCell.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 09/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var coverView: SwiftShadowImageView!
    
    var movieId: Int?
    var genre: Genre?

    override func prepareForReuse() {
        super.prepareForReuse()
        clearImage()
    }
    
    func clearImage() {
        DispatchQueue.main.async {
            self.coverView.image = nil
            self.coverView.alpha = 0.0
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func loadImage(from urlString: String) {
        NetworkService.fetchImage(from: urlString, size: 300) { (result) in
            do {
                let imageData = try result.get()
                DispatchQueue.main.async {
                    self.coverView.image = nil
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.coverView.image = UIImage(data: imageData)
                    
                    UIView.animate(withDuration: 0.4, delay: 0, options: .curveLinear, animations: {
                        self.coverView.alpha = 1.0
                    })
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
    
    func setTileLabel(with text: String) {
        DispatchQueue.main.async {
            self.titleLabel.text = text
            self.titleLabel.numberOfLines = 0
            self.titleLabel.sizeToFit()
        }
    }
    
    // Set failed image instead.
    func setCellToFault() {
        titleLabel.text = "Faild..."
        coverView.backgroundColor = .red
    }
    
}

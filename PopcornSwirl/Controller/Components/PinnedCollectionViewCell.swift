//
//  PinnedCollectionViewCell.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 21/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class PinnedCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "pinnedCell"
    
    var movieId: Int?
    var genre: Genre?
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // TODO: This must be able to load the same MovieCollectionViewCell.. Or something similare...
    func loadImage(with id: Int) {
           NetworkService.lookup(id: id) { (result) in
               switch result {
               case .success(let movies):
                   if let movie = movies.results.first {
                       let imageURL = movie.artworkUrl100
                       NetworkService.fetchImage(from: imageURL, size: 300) { (result) in
                           do {
                               let imageData = try result.get()
                               DispatchQueue.main.async {
                                print("Loading complete")
//                                   self.activityIndicator.stopAnimating()
//                                   self.activityIndicator.isHidden = true
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
    
    
}

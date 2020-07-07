//
//  HeaderCollectionReusableView.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 10/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit


protocol HeaderCollectionReusableViewDelegate {
    func showAllTapped(genre: Genre)
}

class HeaderCollectionReusableView: UICollectionReusableView {
    
    var delegate: HeaderCollectionReusableViewDelegate?
    var genre: Genre?
    
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var gradientLine: GradientView!
    @IBOutlet weak var showAllButton: UIButton!
    
    
    @IBAction func showAllButton(_ sender: Any) {
        if let genre = genre {
            delegate?.showAllTapped(genre: genre)
        }
    }
    
}

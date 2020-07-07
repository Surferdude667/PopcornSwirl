//
//  DetailViewControllerDelegate.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 26/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation

protocol DetailViewControllerDelegate {
    
    func movieAdditionsRemoved(at indexPath: IndexPath?, type: AdditionType)
    func movieAdditionsAdded(additions: [SavedMovieAddition?], type: AdditionType)
    
}

extension DetailViewControllerDelegate {
    
    func movieAdditionsRemoved(at indexPath: IndexPath?, type: AdditionType) { }
    func movieAdditionsAdded(additions: [SavedMovieAddition?], type: AdditionType) { }
    
}

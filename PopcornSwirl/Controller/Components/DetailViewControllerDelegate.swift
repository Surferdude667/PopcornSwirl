//
//  DetailViewControllerDelegate.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 26/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation

protocol DetailViewControllerDelegate {
    func bookmarkAdditionsRemoved(at indexPath: IndexPath?)
    func bookmarkAdditionsAdded(additions: [SavedMovieAddition?])
    
    func watchedAdditionsRemoved(at indexPath: IndexPath?)
    func watchedAdditionsAdded(additions: [SavedMovieAddition?])
}

extension DetailViewControllerDelegate {
    func bookmarkAdditionsRemoved(at indexPath: IndexPath?) { }
    func bookmarkAdditionsAdded(additions: [SavedMovieAddition?]) { }
    
    func watchedAdditionsRemoved(at indexPath: IndexPath?) { }
    func watchedAdditionsAdded(additions: [SavedMovieAddition?]) { }
}

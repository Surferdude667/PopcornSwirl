//
//  CoreDataManager.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 17/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit
import CoreData

enum CoreDataErrors: Error {
    case additionNotFound
    case fetchFailed
    case updateFailed
}

class CoreDataManager {
    
    var context: NSManagedObjectContext
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    func addMovieAddition(id: Int, note: String? = nil, watched: Bool? = nil, bookmarked: Bool? = nil ) {
        let movieAddition = NSEntityDescription.insertNewObject(forEntityName: SavedMovieAddition.entityName, into: context) as! SavedMovieAddition
        let watchedAddition = NSEntityDescription.insertNewObject(forEntityName: Watch.entityName, into: context) as! Watch
        let bookmarkedAddition = NSEntityDescription.insertNewObject(forEntityName: Bookmark.entityName, into: context) as! Bookmark
        
        movieAddition.movieID = Int32(id)
        watchedAddition.movieAddition = movieAddition
        bookmarkedAddition.movieAddition = movieAddition
        
        if let note = note { movieAddition.note = note }
        
        if let watched = watched {
            if watched == true {
                watchedAddition.isWatched = true
                watchedAddition.date = Date()
            } else if watched == false {
                watchedAddition.isWatched = false
                watchedAddition.date = nil
            }
        }
        
        if let bookmarked = bookmarked {
            if bookmarked == true {
                bookmarkedAddition.isBookmarked = true
                bookmarkedAddition.date = Date()
            } else if bookmarked == false {
                bookmarkedAddition.isBookmarked = false
                bookmarkedAddition.date = nil
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Save failed: \(error)")
        }
        
    }
    
    func updateMovieAdditionDates(id: Int, watched: Date? = nil, bookmarked: Date? = nil) {
        
    }
    
    func checkExistanceOfMovieAddition(id: Int) -> Result<SavedMovieAddition, CoreDataErrors> {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: SavedMovieAddition.entityName)
        request.predicate = NSPredicate(format: "%K == \(id)", #keyPath(SavedMovieAddition.movieID))
        
        do {
            let fetch = try context.fetch(request)
            if let result = fetch.first as? SavedMovieAddition {
                return.success(result)
            } else {
                return.failure(.additionNotFound)
            }
        } catch {
            return.failure(.fetchFailed)
        }
    }
    
}

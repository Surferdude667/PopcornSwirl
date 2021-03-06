//
//  CoreDataManager.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 17/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit
import CoreData

enum CoreDataError: Error {
    case additionNotFound
    case saveFailed
    case fetchFailed
    case updateFailed
}

class CoreDataManager {
    
    var context: NSManagedObjectContext
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    func addMovieAddition(id: Int, note: String? = nil, watched: Bool? = nil, bookmarked: Bool? = nil) throws {
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
        
        do { try context.save() }
        catch { throw CoreDataError.saveFailed }
    }
    
    // Sets the specified movie to nil
    func setNoteToNill(id: Int) {
        do {
            let movieAddition = try fetchSavedMovieAddition(id: id).get()
            movieAddition.note = nil
        } catch { print(error) }
        
        do { try context.save() }
        catch { print("Failed to set note to nil: \(error)") }
    }
    
    // Tries to fetch the SavedMovieAddition and returns either an CoreDataError or if suceess the fetched MovieAddition object.
    func fetchSavedMovieAddition(id: Int) -> Result<SavedMovieAddition, CoreDataError> {
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
    
    func fetchSavedMovieAdditionList(of type: AdditionType) throws -> [SavedMovieAddition] {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: SavedMovieAddition.entityName)
        if type == .bookmarked {
            let sortDescriptor = NSSortDescriptor(keyPath: \SavedMovieAddition.bookmarked?.date, ascending: false)
            request.predicate = NSPredicate(format: "%K == YES", #keyPath(SavedMovieAddition.bookmarked.isBookmarked))
            request.sortDescriptors = [sortDescriptor]
        }
        if type == .watched {
            let sortDescriptor = NSSortDescriptor(keyPath: \SavedMovieAddition.watched?.date, ascending: false)
            request.predicate = NSPredicate(format: "%K == YES", #keyPath(SavedMovieAddition.watched.isWatched))
            request.sortDescriptors = [sortDescriptor]
        }
        
        do {
            let fetch = try context.fetch(request)
            
            if fetch.count > 0 {
                return fetch as! [SavedMovieAddition]
            } else {
                throw CoreDataError.additionNotFound
            }
        } catch {
            throw CoreDataError.fetchFailed
        }
    }
}

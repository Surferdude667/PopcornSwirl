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
    
    func addOrUpdateMovieAddition(id: Int, note: String? = nil, watched: Bool? = nil, bookmarked: Bool? = nil ) {
        
    }
    
    func updateMovieAdditionDates(id: Int, watched: Date? = nil, bookmarked: Date? = nil) {
        
    }
    
    func checkExistanceOfMovieAddition(id: Int) -> Result<SavedMovieAddition, CoreDataErrors> {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: SavedMovieAddition.entityName)
        request.predicate = NSPredicate(format: "movieID == \(id)")
        
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

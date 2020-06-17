//
//  SavedDates.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 17/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import CoreData

class SavedDates: NSManagedObject {
    
    static var entityName: String { return "SavedDates" }
    
    // Attributes
    @NSManaged var bookmarkedDate: Date?
    @NSManaged var watched: Date?
    
    // Relationships
    @NSManaged var savedMovieAdditions: SavedMovieAdditions
}

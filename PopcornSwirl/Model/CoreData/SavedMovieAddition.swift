//
//  SavedMovieAdditions.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 17/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import CoreData

class SavedMovieAddition: NSManagedObject {
    
    static var entityName: String { return "SavedMovieAddition" }
    
    // Attributes
    @NSManaged var movieID: Int16
    @NSManaged var note: String?
    @NSManaged var watched: Bool
    @NSManaged var bookmarked: Bool
    
    // Relationships
    @NSManaged var savedDates: SavedDates?
}

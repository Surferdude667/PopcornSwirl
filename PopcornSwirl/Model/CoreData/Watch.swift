//
//  Watch.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 19/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import CoreData

class Watch: NSManagedObject {
    
    static var entityName: String { return "Watch" }
    
    // Attributes
    @NSManaged var isWatched: Bool
    @NSManaged var date: Date?
    
    // Relationships
    @NSManaged var movieAddition: SavedMovieAddition
}

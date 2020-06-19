//
//  Bookmark.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 19/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import CoreData

class Bookmark: NSManagedObject {
    
    static var entityName: String { return "Bookmark" }
    
    // Attributes
    @NSManaged var isBookmarked: Bool
    @NSManaged var date: Date?
    
    // Relationships
    @NSManaged var movieAddition: SavedMovieAddition
}

//
//  CoreDataManager.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 17/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager {
    
    var context: NSManagedObjectContext
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    func addMovieAddition(with id: Int16) {
        
    }
}

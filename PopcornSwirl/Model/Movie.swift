//
//  Movie.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 05/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation

struct Details: Codable {
    var wrapperType: String
    var artistName: String
    var primaryGenreName: String
}


struct Movie: Codable {
    
    var results = [Details]()
    
    
    
    
    
//    var id: String
//    var isPublic: Bool
//    var description: String
    
    // Workaround since "public" is a reserved keyboard in Swift.
//    enum CodingKeys: String, CodingKey {
//        case isPublic = "public", id, description
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        self.id = try container.decode(String.self, forKey: .id)
//        self.isPublic = try container.decode(Bool.self, forKey: .isPublic)
//        self.description = try container.decodeIfPresent(String.self, forKey: .description) ?? "Description is nil"
//    }
    
}

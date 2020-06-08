//
//  Movie.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 05/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation

struct iTunesResponse: Codable {
    var resultCount: Int
    var results = [Movie]()
}

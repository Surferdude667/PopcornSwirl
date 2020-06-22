//
//  Movie.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 08/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation

struct Movie: Codable, Hashable {
    var trackId: Int
    var trackName: String
    var primaryGenreName: String
    var releaseDate: String
    var artworkUrl100: String
    var longDescription: String
    var trackViewUrl: String
}

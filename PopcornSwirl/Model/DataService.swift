//
//  DataService.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 05/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation

enum genre: String {
    case action = "Action+&+Adventure"
    case drama = "Drama"
    case romance = "Romance"
    case thriller = "Thriller"
}


class DataService {
    
    static let shared = DataService()
    
    func search(genre: genre, limit: Int, completion: @escaping (Result<iTunesResponse, Error>) -> Void) {
        var componentURL = URLComponents()
        componentURL.scheme = "https"
        componentURL.host = "itunes.apple.com"
        componentURL.path = "/search"
        
        let termQueryItem = URLQueryItem(name: "term", value: genre.rawValue)
        let entityQueryItem = URLQueryItem(name: "entity", value: "movie")
        let attributeQueryItem = URLQueryItem(name: "attribute", value: "genreTerm")
        let limitQueryItem = URLQueryItem(name: "limit", value: "\(limit)")
        componentURL.queryItems = [termQueryItem, entityQueryItem, attributeQueryItem, limitQueryItem]
        
        guard let validURL = componentURL.url else {
            print("URL creation failed...")
            return
        }
        
        URLSession.shared.dataTask(with: validURL) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("API response code: \(httpResponse.statusCode)")
            }
            
            guard let validData = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
                let movies = try JSONDecoder().decode(iTunesResponse.self, from: validData)
                completion(.success(movies))
            } catch let serializationError {
                completion(.failure(serializationError))
            }
            
        }.resume()
    }
    
    
    func lookup(id: Int, completion: @escaping (Result<iTunesResponse, Error>) -> Void) {
        var componentURL = URLComponents()
        componentURL.scheme = "https"
        componentURL.host = "itunes.apple.com"
        componentURL.path = "/lookup"
        
        let idQueryItem = URLQueryItem(name: "id", value: "\(id)")
        componentURL.queryItems = [idQueryItem]
        
        guard let validURL = componentURL.url else {
            print("URL creation failed...")
            return
        }
        
        URLSession.shared.dataTask(with: validURL) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("API response code: \(httpResponse.statusCode)")
            }
            
            guard let validData = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
                let movies = try JSONDecoder().decode(iTunesResponse.self, from: validData)
                completion(.success(movies))
            } catch let serializationError {
                completion(.failure(serializationError))
            }
            
        }.resume()
    }
    
}

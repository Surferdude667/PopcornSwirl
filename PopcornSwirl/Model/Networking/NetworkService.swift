//
//  DataService.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 05/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation

// TODO: Impment custom error types
enum NetworkError: Error {
    case noInternetConnection
    case serverError
    case emptyResult
}

class NetworkService {
    
    // MARK:- Search request
    static func search(genre: Genre, limit: Int, completion: @escaping (Result<iTunesResponse, Error>) -> Void) {
        var componentURL = URLComponents()
        componentURL.scheme = "https"
        componentURL.host = "itunes.apple.com"
        componentURL.path = "/search"
        
        let term = URLQueryItem(name: "term", value: genre.rawValue)
        let limit = URLQueryItem(name: "limit", value: "\(limit)")
        let entity = URLQueryItem(name: "entity", value: "movie")
        let attribute = URLQueryItem(name: "attribute", value: "genreTerm")
        
        componentURL.queryItems = [term, entity, attribute, limit]
        
        guard let validURL = componentURL.url else {
            print("URL creation failed...")
            return
        }
        
        // TODO: Throw errors based on API response...
        URLSession.shared.dataTask(with: validURL) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("API response code (Search): \(httpResponse.statusCode)")
                print("Searched for: \(validURL)")
            }
            
            guard let validData = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
                let movies = try JSONDecoder().decode(iTunesResponse.self, from: validData)
                if movies.resultCount == 0 {
                    completion(.failure(NetworkError.emptyResult))
                } else {
                    completion(.success(movies))
                }
            } catch let serializationError {
                completion(.failure(serializationError))
            }
            
        }.resume()
    }
    
    // MARK:- Lookup request
    static func lookup(id: Int, completion: @escaping (Result<iTunesResponse, Error>) -> Void) {
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
                //print("API response code (Lookup): \(httpResponse.statusCode)")
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
    
    // MARK:- Image fetching
    static func fetchImage(from url: String, size: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        
        let sizedURL = url.replacingOccurrences(of: "100x100bb", with: "\(size)x\(size)")
        
        guard let validURL = URL(string: sizedURL) else {
            print("URL creation failed...")
            return
        }
        
        URLSession.shared.dataTask(with: validURL) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                
                if httpResponse.statusCode == 500 {
                    completion(.failure(NetworkError.serverError))
                }
            }
            
            if let validData = data, error == nil {
                completion(.success(validData))
            } else {
                completion(.failure(error!))
            }
            
        }.resume()
    }
    
}

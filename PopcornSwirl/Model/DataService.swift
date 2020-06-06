//
//  DataService.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 05/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation

class DataService {
    
    static let shared = DataService()
    //fileprivate let baseURLString = "https://api.github.com"
    
    func fetch(completion: @escaping (Result<Movie, Error>) -> Void) {
        
        var componentURL = URLComponents()
        componentURL.scheme = "https"
        componentURL.host = "itunes.apple.com"
        componentURL.path = "/lookup"
        
        //componentURL.fragment = "id=909253"
        
        let queryItem = URLQueryItem(name: "id", value: "909253")
        
        componentURL.queryItems = [queryItem]
        
        print(componentURL)
        
        
        guard let validURL = componentURL.url else {
            print("URL creation failed...")
            return
        }
        
        URLSession.shared.dataTask(with: validURL) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("API Status: \(httpResponse.statusCode)")
            }
            
            guard let validData = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
                let movies = try JSONDecoder().decode(Movie.self, from: validData)
                completion(.success(movies))
            } catch let serializationError {
                completion(.failure(serializationError))
            }
            
            
        }.resume()
    }
    
}

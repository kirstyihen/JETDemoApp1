//
//  NetworkManager.swift
//  IOS Coding Assessment Demo1
//
//  Created by Kirsty Ihenetu on 3/28/25.
//
import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    //private let baseURL = "https://uk.api.just-eat.io/discovery/uk/restaurants/enriched/bypostcode/"
    
    func fetchRestaurants(postcode: String, completion: @escaping (Result<RestaurantResponse, Error>) -> Void) {
        // Your existing networking code, but ensure it decodes RestaurantResponse
        // Example:
        let url = URL(string: "https://uk.api.just-eat.io/discovery/uk/restaurants/enriched/bypostcode/\(postcode)")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(RestaurantResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

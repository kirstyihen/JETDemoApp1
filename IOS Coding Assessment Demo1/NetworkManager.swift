//
//  NetworkManager.swift
//  IOS Coding Assessment Demo1
//
//  Created by Kirsty Ihenetu on 3/28/25.
//
import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://uk.api.just-eat.io/discovery/uk/restaurants/enriched/bypostcode/"
    
    func fetchRestaurants(postcode: String, completion: @escaping (Result<[Restaurant], Error>) -> Void) {
        let cleanedPostcode = postcode.replacingOccurrences(of: " ", with: "")
        let urlString = baseURL + cleanedPostcode
        
        print("🌐 Attempting to fetch from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("🔴 Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            print("🟢 HTTP Status: \(httpResponse.statusCode)")
            
            guard let data = data else {
                completion(.failure(URLError(.cannotParseResponse)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(RestaurantResponse.self, from: data)
                print("✅ Decoded \(response.restaurants.count) restaurants")
                completion(.success(response.restaurants)) //when decoded 0 restaurant print "no restaurants in your area!"
                //print("✅ First restaurant delivery time:", response.restaurants.first?.deliveryEtaMinutes ?? "N/A")
                //completion(.success(response.restaurants))
                
            } catch {
                print("❌ Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    print("Detailed decoding error: \(decodingError.localizedDescription)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
}

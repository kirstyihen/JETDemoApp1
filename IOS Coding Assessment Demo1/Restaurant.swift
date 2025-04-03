//
//  Restaurant.swift
//  IOS Coding Assessment Demo1
//
//  Created by Kirsty Ihenetu on 3/28/25.
//

import SwiftUI

struct RestaurantResponse: Codable {
    let restaurants: [Restaurant]
    let metaData: MetaData?
    
    struct MetaData: Codable {
        let canonicalName: String?
        let district: String?
        let postalCode: String?
        let area: String?
        let location: Location?
        //let cuisineDetails: [CuisineCategory]
        
//        struct CuisineCategory: Codable, Identifiable {
//            var id = UUID()
//            let name: String
//            let uniqueName: String
//            let count: Int
//        }
        
        struct Location: Codable {
            let type: String
            let coordinates: [Double]
        }
    }
}



struct Restaurant: Codable, Identifiable {
    let id: String  // Changed from UUID to String
    let name: String
    let logoUrl: URL
    let cuisines: [Cuisine]
    let rating: Rating
    let address: Address
    let deliveryEtaMinutes: DeliveryEtaMinutes?
    
    struct Cuisine: Codable {
        let name: String
        let uniqueName: String?
    }
    
    struct Rating: Codable {
        let starRating: Double
        let count: Int
    }
    
    struct Address: Codable {
        let firstLine: String
        let city: String
        let postalCode: String
        
        var formatted: String {
            "\(firstLine), \(city), \(postalCode)"
        }
    }
    
    struct DeliveryEtaMinutes: Codable {
        let rangeLower: Int
        let rangeUpper: Int
        
        var formatted: String {
            "\(rangeLower)-\(rangeUpper) mins"
        }
    }
}

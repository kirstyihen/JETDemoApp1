//
//  RestaurantCell.swift
//  IOS Coding Assessment Demo1
//
//  Created by Kirsty Ihenetu on 3/28/25.
//

import SwiftUI

struct RestaurantRow: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AsyncImage(url:restaurant.logoUrl) //restaurant image from logoUrl in API
                Text(restaurant.name)
                    .font(.system(.headline, design: .serif))
                
                Spacer()
                
                RatingView(starRating: restaurant.rating.starRating, count: restaurant.rating.count)
            }
            
            Text(restaurant.cuisines.map { $0.name }.joined(separator: ", "))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack{
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.blue)
                Text(restaurant.address.formatted)
                    .font(.caption)
                if let deliveryTime = restaurant.deliveryEtaMinutes {
                    DeliveryView(deliveryTime: deliveryTime)
                } else {
                    Text("Delivery time unavailable")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)
    }
}

struct RatingView: View {
    let starRating: Double
    let count: Int
    
    var body: some View {
        HStack(spacing: 4) {  
            Image(systemName: "star.fill")
                .foregroundColor(.orange)
            
            // Combined rating and count text
            Text("\(String(format: "%.1f", starRating))")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text("(\(count))")
                .font(.subheadline)
                .fontWeight(.light)
                .foregroundColor(.gray)
        }
    }
}

struct DeliveryView: View {
    let deliveryTime: Restaurant.DeliveryEtaMinutes
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .foregroundColor(.green)
            
            Text(deliveryTime.formatted)
                .font(.caption)
                .foregroundColor(.green)
        }
        .padding(6)
        .background(Color.green.opacity(0.2))
        .cornerRadius(6)
    }
}



# Restaurant Finder App  
A SwiftUI application for browsing restaurants by postcode with filtering capabilities.

## Features  
- Displays all required restaurant data points:  
  🍽️ **Name**  
  🌮 **Cuisines** (type and count)  
  ⭐ **Rating** (numeric star value)  
  📍 **Address** (formatted as "Street, City, Postcode")  
- Filter by:  
  - Sort by Default, Rating, or Delivery Time
  - Minimum star rating (1-5)  
  - Delivery time range (5-60 mins)  
  - Cuisine type and Restaurant Offerings 

## How to Run  
### Xcode Setup  
1. Open `RestaurantFinder.xcodeproj`  
2. **Build**: `Product > Build` (⌘B)  
3. **Run**: Click the play button ▶️ in top toolbar after build succeeds  

### Simulator Scroll Fix  
If scrolling isn't working in simulator:  
1. Open macOS `System Settings > Accessibility`  
2. Select `Pointer Control > Trackpad Options`  
3. Enable `Dragging` and select `Three finger drag`  

## Implementation Notes  
### Assumptions  
- API returns `RestaurantResponse` with nested:  
  ```swift
  struct RestaurantResponse {
      let restaurants: [Restaurant]
      let metaData: MetaData? // Contains cuisineDetails
  }
  ```
- Delivery time uses `rangeLower`/`rangeUpper` values from `deliveryEtaMinutes`  
- Rating displays raw `starRating` without rounding  

### Improvements Planned  
- [ ] Add loading skeletons during API calls  
- [ ] Implement cuisine search within filter panel  
- [ ] Cache API responses for offline support  
- [ ] Add map view for address visualization  

## Assessment Criteria Verification  
| Requirement        | Implementation |  
|--------------------|----------------|  
| Name Display       | ✅ `restaurant.name` |  
| Cuisines Display   | ✅ `restaurant.cuisines.map`, Lists all types with counts |  
| Rating Display     | ✅ `restaurant.rating.starRating` |  
| Address Display    | ✅ `restaurant.address.formatted`, Formatted as "FirstLine, City, Postcode" |  



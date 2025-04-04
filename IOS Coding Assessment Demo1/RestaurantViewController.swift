//
//  RestaurantViewController.swift
//  IOS Coding Assessment Demo1
//
//  Created by Kirsty Ihenetu on 3/28/25.
//
import SwiftUI

struct RestaurantView: View {
    @StateObject private var viewModel = RestaurantViewModel()
    @State private var searchText = ""
    @State private var showFilterSheet = false
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {  // Remove default spacing
                // Header image inside the NavigationStack
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .background(Color("JETorange"))

                searchField
                    .font(.title2)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .scaleEffect(1.05)
                    .cornerRadius(15)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)// Center vertically
                        .scaleEffect(2.0)
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                } else if let error = viewModel.errorMessage {
                    errorView(error)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)// Center vertically
                } else {
                    ScrollView{
                        restaurantList
                    }
                }
            }
        }
    }
    
    private var contentSection: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                // Always show errors first
                errorView(error)
            } else if viewModel.restaurants.isEmpty {
                // Only show empty state if no error exists
                emptyStateView
            } else {
                restaurantList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private var emptyStateView: some View {
        VStack {
        }
    }
    
    private var searchField: some View {
        HStack {
            TextField("Enter UK Postcode...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .cornerRadius(7)
                .keyboardType(.default)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .focused($isSearchFieldFocused)
                .onSubmit {
                    searchRestaurants()
                }
                .submitLabel(.search)
            
            Button {
                searchRestaurants()
            } label: {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.orange)
                    .font(.title)
            }
            .disabled(searchText.isEmpty)
            
            Button {
                showFilterSheet.toggle()
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.title)
                    .foregroundColor(.orange)
            }
            .popover(isPresented: $showFilterSheet) {
                FilterSortView(
                    selectedSortOption: $viewModel.sortOption,  // Now matches types
                    cuisineDetails: viewModel.cuisineDetails
                )
                .padding()
            }
            .disabled(searchText.isEmpty)
        }
    }
    
// Custom view for filters/sorting
    struct FilterSortView: View {
        // Receive cuisine data as a parameter
        @Binding var selectedSortOption: RestaurantViewModel.SortOption?   // Add this binding
        let cuisineDetails: [Cuisine]
        @State private var minRating = 0
        @State private var maxDeliveryTime: Double = 30
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Refine Search")
                    .font(.title)
                    .fontWeight(.bold)
                
                Divider()
                
                // Sort Options
                Section {
                    Menu {
                        Button(action: { selectedSortOption = nil }) {
                            HStack {
                                Text("None")
                                if selectedSortOption == nil {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        Button(action: {
                            selectedSortOption = .rating
                        }) {
                            HStack {
                                Text("Rating")
                                if selectedSortOption == .rating {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        
                        Button(action: {
                            selectedSortOption = .deliveryTime
                        }) {
                            HStack {
                                Text("Delivery Time")
                                if selectedSortOption == .deliveryTime {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    } label: {
                        Label(
                            title: {
                                Text(selectedSortOption?.rawValue ?? "Sort By")
                            },
                            icon: {
                                Image(systemName: selectedSortOption?.systemImage ?? "arrow.up.arrow.down")
                            }
                        )
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    }
                }
                
                // Filter by Rating
                Section {
                    Text("Rating").bold()
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                minRating = star
                            } label: {
                                Image(systemName: star <= minRating ? "star.fill" : "star")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                
                // Filter by Delivery Time
                Section {
                    HStack{
                        Text("Delivery Time").bold()
                        Image(systemName: "clock.fill")
                    }
                    VStack {
                        Slider(value: $maxDeliveryTime, in: 5...30, step: 5)
                        Text("Up to \(Int(maxDeliveryTime)) min").font(.caption)
                    }
                }
                
                // Cuisine Filters
                Section {
                    Text("Cuisine Types").bold()
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(cuisineDetails) { cuisine in  // No need for id: when using Identifiable
                                Button(action: {}) {
                                    Text("\(cuisine.name) (\(cuisine.count ?? 0))")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(.orange)
                                        .foregroundColor(.white)
                                        .cornerRadius(5)
                                }
                            }
                        }
                    }
                }
                
                // Apply Button
                Button("Apply") {
                    // Apply filters here
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            .padding()
            .frame(width: 300)
        }
    }
    
    private func searchRestaurants() {
        isSearchFieldFocused = false
        viewModel.fetchRestaurants(postcode: searchText)
    }
    
    private var restaurantList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {  // Added spacing between items
                ForEach(viewModel.restaurants) { restaurant in
                    RestaurantRow(restaurant: restaurant)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 8)  // Add vertical padding
        }
        .refreshable {
            searchRestaurants()
        }
    }

    
    private func errorView(_ message: String) -> some View {
        VStack {
            Image("pot")
                .font(.largeTitle)
            
            Text(message)
                .multilineTextAlignment(.center)
                .font(.system(.title3)).bold()
                .padding(.bottom, 25)
        }
        .foregroundColor(Color("grayblue"))
        .padding()
        .frame(alignment: .center)
    }
}

class RestaurantViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var cuisineDetails: [Cuisine] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var sortOption: SortOption? = nil
    
    enum SortOption: String, CaseIterable{
        case none = "None"
        case rating = "Rating"
        case deliveryTime = "Delivery Time"
        
        var systemImage: String{
            switch self{
            case .none: return "arrow.up.arrow.down"
            case .rating: return "star.fill"
            case .deliveryTime: return "clock"
                
            }
        }
    }
    
    func sortRestaurants(){
        guard let option = sortOption else{
            return
        }
        switch option {
        case .rating:
            restaurants.sort { $0.rating.starRating > $1.rating.starRating }
        case .deliveryTime:
            restaurants.sort { ($0.deliveryEtaMinutes?.rangeLower ?? 0) < ($1.deliveryEtaMinutes?.rangeLower ?? 0) }
        case .none:
            break // No sorting
        }
    }
    
    func fetchRestaurants(postcode: String) {
        guard !postcode.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        let cleanedPostcode = postcode.replacingOccurrences(of: " ", with: "")
        
        NetworkManager.shared.fetchRestaurants(postcode: cleanedPostcode) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let restaurants):
                    if restaurants.isEmpty {
                        self?.restaurants = []
                        self?.errorMessage = "Uh-oh, no restaurants nearby :( But maybe it's time for a kitchen adventure?"
                    }else {
                        self?.restaurants = Array(restaurants.prefix(20))
                        self?.errorMessage = nil
                    }
                case .failure(let error):
                    self?.errorMessage = self?.errorMessage(for: error)
                    self?.restaurants = []
                    
                }
            }
        }
    }
    
    private func errorMessage(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "No internet connection"
            case .timedOut:
                return "Request timed out"
            default:
                return "Network error occurred"
            }
        }
        return "Failed to load restaurants"
    }
}

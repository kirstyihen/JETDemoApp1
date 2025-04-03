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
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {  // Remove default spacing
                // Header image inside the NavigationStack
                Image("jet")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                
//                ScrollView(.horizontal){
//                    //horizontal
//                }
                
                searchField
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)// Center vertically
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
    
//    private var sortingPicker: some View {
//        Picker("Sort by", selection: $viewModel.sortOption) {
//            ForEach(RestaurantViewModel.SortOption.allCases, id: \.self) { option in
//                Text(option.rawValue).tag(option)
//            }
//        }
//        .pickerStyle(.segmented)
//        .padding(.horizontal)
//        .onChange(of: viewModel.sortOption) { _ in
//            viewModel.sortRestaurants()
//        }
//    }
    
    private var emptyStateView: some View {
        VStack {

        }
    }
    
    private var searchField: some View {
        HStack {
            TextField("Enter UK Postcode...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .cornerRadius(5)
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
            
            Menu {
                // Other menu items...
                
                Menu("Filter by Rating") {
                    ForEach(1...5, id: \.self) { rating in
                        Button {
                            // Filter by selected rating
                        } label: {
                            HStack {
                                Text("\(rating)+")
                                Spacer()
                                ForEach(1...rating, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                }
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.orange)
                    .font(.title)
            }
            .disabled(searchText.isEmpty)
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
            Spacer().frame(height: 50) // Adjust this value to control how high up the content appears
            
            Image("pot")
                .font(.largeTitle)
            
            Text(message)
                .multilineTextAlignment(.center)
                .font(.system(.title3, design: .serif))
                .padding(.bottom, 25)
            
            Spacer() // Pushes content upward
            Spacer()
        }
        .foregroundColor(Color("grayblue"))
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // Aligns content to top
    }
}

class RestaurantViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var sortOption: SortOption = .rating
    
    enum SortOption: String, CaseIterable{
        
        case rating = "Rating"
        case deliveryTime = "Delivery Time"
    }
    
    func sortRestaurants(){
        switch sortOption{
        case .rating:
            restaurants.sort {$0.rating.starRating > $1.rating.starRating}
        case .deliveryTime:
            restaurants.sort { ($0.deliveryEtaMinutes?.rangeLower ?? 0) < ($1.deliveryEtaMinutes?.rangeLower ?? 0) }

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

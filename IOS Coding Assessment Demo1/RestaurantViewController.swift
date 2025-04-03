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
                FilterSortView()
                    .padding()
            }
            .disabled(searchText.isEmpty)
        }
    }
    
    // Custom view for filters/sorting
    struct FilterSortView: View {
        @State private var minRating = 0
        @State private var maxDeliveryTime : Double = 30
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Refine Search")
                    .font(.title)
                    .fontWeight(.bold)
                Divider()
                Spacer()
                // Sort Options
                Section {
                    Menu {
                        Text("Rating")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Text("Delivery Time")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    } label: {
                        Label("Sort By", systemImage: "chevron.down") // Adds dropdown arrow
                            .fontWeight(.bold) // Makes title bold
                            .foregroundColor(.black) // Ensures text is black
                    }

                }
                Spacer()
                
                // Filter by Rating (Stars)
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
                Spacer()
                
                // Filter by Delivery Time (Slider)
                Section {
                    Text("Max Delivery Time").bold()
                    VStack{
                        Slider(value: $maxDeliveryTime, in: 5...30, step: 5)
                        Text("Up to \(Int(maxDeliveryTime)) min").font(.caption)
                    }
                }
                Spacer()
                
                Section{
                    HStack{
                        Button("Pizza"){}.background(.orange).foregroundColor(.white).cornerRadius(5)
                        Button("Pizza"){}.background(.orange).foregroundColor(.white).cornerRadius(5)
                        Button("Pizza"){}.background(.orange).foregroundColor(.white).cornerRadius(5)
                        Button("Pizza"){}.background(.orange).foregroundColor(.white).cornerRadius(5)
                        Button("Pizza"){}.background(.orange).foregroundColor(.white).cornerRadius(5)
                    }
                }
                Spacer()
                
                // Apply Button
                Button("Apply") {
                    // Apply filters & sorting
                }
                .buttonStyle(.borderedProminent)
            }
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

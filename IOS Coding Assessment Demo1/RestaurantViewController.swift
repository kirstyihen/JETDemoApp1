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
            VStack(spacing: 0) {
                // Header image
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
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .scaleEffect(2.0)
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                } else if !viewModel.errorMessage.isEmpty {
                    errorView(viewModel.errorMessage)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                } else {
                    ScrollView {
                        restaurantList
                    }
                }
            }
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
                FilterSortView(viewModel: viewModel)
                    .padding()
            }
            .disabled(searchText.isEmpty)
        }
    }
    
    private var restaurantList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.displayedRestaurants) { restaurant in
                    RestaurantRow(restaurant: restaurant)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 8)
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
    
    private func searchRestaurants() {
        isSearchFieldFocused = false
        viewModel.fetchRestaurants(postcode: searchText)
    }
}

struct FilterSortView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: RestaurantViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Refine Search")
                    .font(.title)
                    .fontWeight(.bold)
                Image(systemName: "magnifyingglass")
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
            
            Section {
                Text("Sort By").bold()
                Picker("", selection: $viewModel.sortOption) {
                    ForEach(RestaurantViewModel.SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section {
                Text("Rating: \(viewModel.minRating)+").bold()
                HStack {
                    ForEach(1...5, id: \.self) { star in
                        Button {
                            viewModel.minRating = star
                        } label: {
                            Image(systemName: star <= viewModel.minRating ? "star.fill" : "star")
                                .foregroundColor(.orange)
                                .font(.title3)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Section {
                HStack{
                    Text("Delivery Time: \(viewModel.maxDeliveryTime) min").bold()
                    Image(systemName: "car")
                }
                Slider(
                    value: Binding(
                        get: { Double(viewModel.maxDeliveryTime) },
                        set: { viewModel.maxDeliveryTime = Int($0) }
                    ),
                    in: 5...45,
                    step: 5
                )
            }
            
            if !viewModel.cuisineDetails.isEmpty {
                Section {
                    HStack{
                        Text("Cuisines and Offers").bold()
                        Image(systemName: "fork.knife")
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.cuisineDetails) { cuisine in
                                Button {
                                    if viewModel.selectedCuisines.contains(cuisine.uniqueName) {
                                        viewModel.selectedCuisines.remove(cuisine.uniqueName)
                                    } else {
                                        viewModel.selectedCuisines.insert(cuisine.uniqueName)
                                    }
                                } label: {
                                    Text("\(cuisine.name) (\(cuisine.count ?? 0))")
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            viewModel.selectedCuisines.contains(cuisine.uniqueName) ?
                                            Color.orange : Color.gray.opacity(0.2)
                                        )
                                        .foregroundColor(
                                            viewModel.selectedCuisines.contains(cuisine.uniqueName) ?
                                            .white : .primary
                                        )
                                        .cornerRadius(15)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack {
                Button("Reset All") {
                    viewModel.sortOption = .none
                    viewModel.minRating = 0
                    viewModel.maxDeliveryTime = 5
                    viewModel.selectedCuisines = []
                }
                .buttonStyle(.bordered)
                .tint(.gray)
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(width: 300, height: 500)
    }
}

class RestaurantViewModel: ObservableObject {
    @Published var allRestaurants: [Restaurant] = []
    @Published var displayedRestaurants: [Restaurant] = []
    @Published var cuisineDetails: [Cuisine] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    @Published var sortOption: SortOption = .none {
        didSet { applyFilters() }
    }
    @Published var minRating: Int = 0 {
        didSet { applyFilters() }
    }
    @Published var maxDeliveryTime: Int = 60 {
        didSet { applyFilters() }
    }
    @Published var selectedCuisines: Set<String> = [] {
        didSet { applyFilters() }
    }
    
    enum SortOption: String, CaseIterable {
        case none = "Default"
        case rating = "Rating"
        case deliveryTime = "Delivery Time"
    }
    
    func applyFilters() {
        var results = allRestaurants
        
        results = results.filter { $0.rating.starRating >= Double(minRating) }
        results = results.filter { ($0.deliveryEtaMinutes?.rangeUpper ?? Int.max) <= maxDeliveryTime }
        
        if !selectedCuisines.isEmpty {
            results = results.filter { restaurant in
                restaurant.cuisines.contains { cuisine in
                    selectedCuisines.contains(cuisine.uniqueName)
                }
            }
        }
        
        switch sortOption {
        case .rating:
            results.sort { $0.rating.starRating > $1.rating.starRating }
        case .deliveryTime:
            results.sort { ($0.deliveryEtaMinutes?.rangeLower ?? 0) < ($1.deliveryEtaMinutes?.rangeLower ?? 0) }
        case .none:
            break
        }
        
        displayedRestaurants = results
    }
    
    func fetchRestaurants(postcode: String) {
        guard !postcode.isEmpty else {
            allRestaurants = []
            displayedRestaurants = []
            errorMessage = "Please enter a valid postcode"
            isLoading = false
            return
        }
        
        isLoading = true
        errorMessage = ""
        let cleanedPostcode = postcode.replacingOccurrences(of: " ", with: "")
        
        NetworkManager.shared.fetchRestaurants(postcode: cleanedPostcode) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    self.allRestaurants = response.restaurants
                    self.cuisineDetails = response.metaData?.cuisineDetails ?? []
                    self.applyFilters()
                    
                    if self.displayedRestaurants.isEmpty {
                        self.errorMessage = "No restaurants match your current filters"
                    }
                    
                case .failure(let error):
                    self.allRestaurants = []
                    self.displayedRestaurants = []
                    self.errorMessage = self.errorMessage(for: error)
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

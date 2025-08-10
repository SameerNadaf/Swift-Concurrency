//
//  SearchableSwiftUI.swift
//  SwiftConcurrency
//
//  Created by Sameer  on 10/08/25.
//

import SwiftUI
import Combine

struct Restaurant: Identifiable, Hashable {
    let id: String
    let name: String
    let cuisine: CuisineOption
}

enum CuisineOption: String {
    case american
    case italian
    case indian
    case japanese
}

final class SearchableDataManager {
    
    func getAllRestourants() async throws -> [Restaurant] {
        [
            Restaurant(id: "1", name: "Burger King", cuisine: .american),
            Restaurant(id: "2", name: "La Fizza", cuisine: .italian),
            Restaurant(id: "3", name: "Hotel Taj", cuisine: .indian),
            Restaurant(id: "4", name: "Sushi House", cuisine: .japanese),
            Restaurant(id: "5", name: "KFC", cuisine: .american),
        ]
    }
}

@MainActor
final class SearchableViewModel: ObservableObject {
    @Published private(set) var allRestaurants: [Restaurant] = []
    @Published private(set) var filteredRestaurants: [Restaurant] = []
    @Published var searchText: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let manager = SearchableDataManager()
    
    var isSearching: Bool { !searchText.isEmpty }
    
    init() {
        addSubcribers()
    }
    
    func loadAllRestaurants() async {
        do {
            allRestaurants = try await manager.getAllRestourants()
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    func addSubcribers() {
        $searchText
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink {[weak self] searchText in
                self?.filterRestaurants(searchText: searchText)
            }
            .store(in: &cancellables)
    }
    
    func filterRestaurants(searchText: String) {
        guard !searchText.isEmpty else {
            return
        }
        
        let search = searchText.lowercased()
        filteredRestaurants = allRestaurants.filter({ restaurant in
            let nameContainsSearchText = restaurant.name.lowercased().contains(search)
            let cuisineContainsSearchText = restaurant.cuisine.rawValue.lowercased().contains(search)
            return nameContainsSearchText || cuisineContainsSearchText
        })
    }
    
}

struct SearchableSwiftUI: View {
    
    @StateObject private var viewModel = SearchableViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.isSearching ? viewModel.filteredRestaurants : viewModel.allRestaurants) { restaurant in
                restaurantRow(restaurant: restaurant)
            }
            .searchable(text: $viewModel.searchText, placement: .automatic, prompt: Text("Search Restaurant..."))
            .navigationTitle("Searchable")
            .task {
                await viewModel.loadAllRestaurants()
            }
        }
    }
}

extension SearchableSwiftUI {
    
    private func restaurantRow(restaurant: Restaurant) -> some View {
        VStack(alignment: .leading) {
            Text(restaurant.name)
                .font(.headline)
            Text(restaurant.cuisine.rawValue.capitalized)
                .font(.caption)
        }
    }
}

#Preview {
    SearchableSwiftUI()
}

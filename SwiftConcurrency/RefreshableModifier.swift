//
//  RefreshableModifier.swift
//  SwiftConcurrency
//
//  Created by Sameer  on 10/08/25.
//

import SwiftUI

final class RefreshableDataManager {
    func refreshData() async throws -> [String] {
        try await Task.sleep(nanoseconds: 3_000_000_000)
        return ["Apple", "Orange", "Banana", "Mango", "Pineapple"].shuffled()
    }
}

@MainActor
final class RefreshableViewModel: ObservableObject {
    @Published var items: [String] = []
    private let manager = RefreshableDataManager()
    
    func refreshItems() async {
        do {
            items = try await manager.refreshData()
        } catch {
            print("Error refreshing data: \(error)")
        }
    }
}

struct RefreshableModifier: View {
    
    @StateObject private var vm = RefreshableViewModel()
    
    var body: some View {
        NavigationStack {
            List(vm.items, id: \.self) { item in
                Text(item)
                    .font(.headline)
            }
            .refreshable {
                await vm.refreshItems()
            }
            .navigationTitle("Refreshable")
        }
        .task {
            await vm.refreshItems()
        }
    }
}

#Preview {
    RefreshableModifier()
}

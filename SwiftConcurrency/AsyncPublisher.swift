//
//  AsyncPublisher.swift
//  SwiftConcurrency
//
//  Created by Sameer  on 10/08/25.
//

import SwiftUI
import Combine

class AsyncPublisherDataModel {
    @Published var data: [String] = []
    
    func downloadData() async {
        data.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        data.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        data.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        data.append("Papaya")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
    }
}

class AsyncPublisherViewModel: ObservableObject {
    @MainActor @Published var items: [String] = []
    private let manager = AsyncPublisherDataModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        featchData()
    }
    
    private func featchData() {
        
        Task {
            for await value in manager.$data.values {
                await MainActor.run {
                    self.items = value
                }
            }
        }
//        manager.$data
//            .receive(on: DispatchQueue.main)
//            .sink { string in
//                self.items = string
//            }
//            .store(in: &cancellables)
    }
    
    func startFetchingData() async {
        await manager.downloadData()
    }
}

struct AsyncPublisher: View {
    
    @StateObject var vm = AsyncPublisherViewModel()
    
    var body: some View {
        VStack {
            List(vm.items, id: \.self) { item in
                Text(item)
            }
        }
        .task {
            await vm.startFetchingData()
        }
    }
}

#Preview {
    AsyncPublisher()
}

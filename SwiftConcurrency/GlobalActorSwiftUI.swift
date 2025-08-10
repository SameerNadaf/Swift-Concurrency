//
//  GlobalActorSwiftUI.swift
//  SwiftConcurrency
//
//  Created by Sameer  on 10/08/25.
//

import SwiftUI

@globalActor struct MyGlobalActor {
    
    static let shared = GlobalActorDataModel()
}

actor GlobalActorDataModel {
    
    func downloadData() -> [String] {
        return ["one", "two", "three", "four", "five", "six"]
    }
}

class GlobalActorViewModel: ObservableObject {
    @MainActor @Published var stringArray: [String] = []
    private let dataModel = MyGlobalActor.shared
    
    @MyGlobalActor
    func loadStringArray() {
        Task {
            let data = await dataModel.downloadData()
            await MainActor.run {
                stringArray = data
            }
        }
    }
}

struct GlobalActorSwiftUI: View {
    
    @StateObject private var viewModel = GlobalActorViewModel()
    
    var body: some View {
        ZStack {
            List(viewModel.stringArray, id: \.self) { item in
                Text(item)
            }
        }
        .task {
            await viewModel.loadStringArray()
        }
    }
}

#Preview {
    GlobalActorSwiftUI()
}

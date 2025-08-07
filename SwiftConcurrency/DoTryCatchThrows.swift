//
//  DoTryCatchThrows.swift
//  SwiftConcurrency
//
//  Created by Sameer  on 06/08/25.
//

import SwiftUI

class DoTryCatchThrowsDataManager {
    
    private let isActive: Bool = false
    
    func getData() throws -> String {
        if isActive {
            return "Data"
        } else {
            throw URLError(.badServerResponse)
        }
    }
}

class DoTryCatchThrowsViewModel: ObservableObject {
    @Published var title: String = "Do Try Catch Throws"
    var dataManager = DoTryCatchThrowsDataManager()
    
    func fetchData() {
        do {
            let newTitle = try dataManager.getData()
            title = newTitle
        } catch let error {
            title = error.localizedDescription
        }
    }
}

struct DoTryCatchThrows: View {
    
    @StateObject var viewModel = DoTryCatchThrowsViewModel()
    
    var body: some View {
        Text(viewModel.title)
            .frame(width: 300, height: 300)
            .background(Color.yellow)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .onTapGesture {
                viewModel.fetchData()
            }
    }
}

#Preview {
    DoTryCatchThrows()
}

//
//  ActorsSwiftUI.swift
//  SwiftConcurrency
//
//  Created by Sameer  on 10/08/25.
//

import SwiftUI

class ClassDataManager {
    static let shared = ClassDataManager()
    private var stringArray: [String] = []
    let task = DispatchQueue(label: "com.ClassDataManager.shared")
    
    private init() { }
    
    func loadData(handler: @escaping(_ title: String?) -> ()) {
        self.task.async {
            self.stringArray.append(UUID().uuidString)
            print(Thread.current)
            handler(self.stringArray.randomElement())
        }
    }
}

actor ActorDataManager {
    static let shared = ActorDataManager()
    private var stringArray: [String] = []
    
    nonisolated let title: String = "Title"
    
    private init() { }
    
    func loadData() -> String? {
        self.stringArray.append(UUID().uuidString)
        print(Thread.current)
        return self.stringArray.randomElement()
    }
}

struct HomeView: View {
    
    private let manager = ActorDataManager.shared
    private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var text: String = ""
    
    var body: some View {
        ZStack {
            Color.green.opacity(0.5)
                .ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onAppear {
            let title = manager.title
            print(title)
        }
        .onReceive(timer) { _ in
            Task {
                if let title = await manager.loadData() {
                    await MainActor.run {
                        text = title
                    }
                }
            }
        }
    }
}

struct SearchView: View {
    
    private let manager = ActorDataManager.shared
    private var timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State private var text: String = ""
    
    var body: some View {
        ZStack {
            Color.red.opacity(0.5)
                .ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            Task {
                if let title = await manager.loadData() {
                    await MainActor.run {
                        text = title
                    }
                }
            }
        }
    }
}

struct ActorsSwiftUI: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            
            Tab("Search", systemImage: "magnifyingglass") {
                SearchView()
            }
        }
    }
}

#Preview {
    ActorsSwiftUI()
}

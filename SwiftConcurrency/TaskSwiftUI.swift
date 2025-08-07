//
//  TaskSwiftUI.swift
//  SwiftConcurrency
//
//  Created by Sameer  on 07/08/25.
//

import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    let url = URL(string: "https://picsum.photos/300")!
    
    func loadImage() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            await MainActor.run {
                image = UIImage(data: data)
                print("Image retrieved")
            }
            try? Task.checkCancellation()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadImage2() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            await MainActor.run {
                image2 = UIImage(data: data)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TaskHomeView: View {
    var body: some View {
        NavigationStack {
            NavigationLink("Go To Detail") {
                TaskSwiftUI()
            }
        }
    }
}
struct TaskSwiftUI: View {
    
    @StateObject var vm = TaskViewModel()
    @State private var imageTask: Task<(), Never>? = nil
    
    var body: some View {
        VStack {
            if let image = vm.image {
                Image(uiImage: image)
            }
            if let image = vm.image2 {
                Image(uiImage: image)
            }
        }
        .task {
            await vm.loadImage()
        }
//        .onDisappear {
//            imageTask?.cancel()
//        }
//        .onAppear {
//            imageTask = Task {
//                await vm.loadImage()
//            }
//            Task(priority: .high) {
//                print("hign : \(Task.currentPriority.rawValue)")
//            }
//            Task(priority: .userInitiated) {
//                print("userInitiated : \(Task.currentPriority.rawValue)")
//            }
//            Task(priority: .medium) {
//                print("medium : \(Task.currentPriority.rawValue)")
//            }
//            Task(priority: .utility) {
//                print("utility : \(Task.currentPriority.rawValue)")
//            }
//            Task(priority: .low) {
//                print("low : \(Task.currentPriority.rawValue)")
//            }
//            Task(priority: .background) {
//                print("background : \(Task.currentPriority.rawValue)")
//            }
//        }
    }
}

#Preview {
    TaskSwiftUI()
}

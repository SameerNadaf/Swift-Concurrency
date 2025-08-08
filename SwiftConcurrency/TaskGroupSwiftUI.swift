//
//  TaskGroupSwiftUI.swift
//  SwiftConcurrency
//
//  Created by Sameer  on 08/08/25.
//

import SwiftUI

class TaskGroupManager {
    
    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
        async let fetchImage1 = downloadImages(url: "https://picsum.photos/200")
        async let fetchImage2 = downloadImages(url: "https://picsum.photos/200")
        async let fetchImage3 = downloadImages(url: "https://picsum.photos/200")
        async let fetchImage4 = downloadImages(url: "https://picsum.photos/200")
        
        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
        
        return [image1, image2, image3, image4]
    }
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        
        let urlString: [String] = [
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200",
            "https://picsum.photos/200"
        ]

        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images: [UIImage] = []
            images.reserveCapacity(urlString.count)
            
            for url in urlString {
                group.addTask {
                    try? await self.downloadImages(url: url)
                }
            }
            
//            group.addTask {
//                try await self.downloadImages(url: "https://picsum.photos/200")
//            }
//            group.addTask {
//                try await self.downloadImages(url: "https://picsum.photos/200")
//            }
//            group.addTask {
//                try await self.downloadImages(url: "https://picsum.photos/200")
//            }
//            group.addTask {
//                try await self.downloadImages(url: "https://picsum.photos/200")
//            }
            
            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            
            return images
        }
    }
    
    private func downloadImages(url: String) async throws -> UIImage {
        
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badServerResponse)
            }
            
        } catch {
            throw URLError(.badServerResponse)
        }
    }
}

class TaskGroupViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    let manager = TaskGroupManager()
    
    func getImages() async {
        if let images = try? await manager.fetchImagesWithTaskGroup() {
            self.images.append(contentsOf: images)
        }
    }
}

struct TaskGroupSwiftUI: View {
    
    @StateObject private var vm = TaskGroupViewModel()
    
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(vm.images, id: \.self) { image in
                        Image(uiImage: image)
                    }
                }
            }
            .navigationTitle("Task Group 😎")
        }
        .task {
            await vm.getImages()
        }
    }
}

#Preview {
    TaskGroupSwiftUI()
}

//
//  AsyncLet.swift
//  SwiftConcurrency
//
//  Created by Sameer  on 08/08/25.
//

import SwiftUI

class AsyncLetViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    let url = URL(string: "https://picsum.photos/200")!
    
    func downloadImages() async throws -> UIImage {
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

struct AsyncLet: View {
    
    @StateObject private var vm = AsyncLetViewModel()
    
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            LazyVGrid(columns: columns) {
                ForEach(vm.images, id: \.self) { image in
                    Image(uiImage: image)
                }
            }
            .navigationTitle("Async Let 🤓")
        }
        .onAppear {
            Task {
                
                async let fetchImage1 = vm.downloadImages()
                async let fetchImage2 = vm.downloadImages()
                async let fetchImage3 = vm.downloadImages()
                async let fetchImage4 = vm.downloadImages()
                
//                let image1 = try await fetchImage1
//                let image2 = try await fetchImage2
//                let image3 = try await fetchImage3
//                let image4 = try await fetchImage4
                let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
                
                vm.images.append(contentsOf: [image1, image2, image3, image4])
                
//                let image1 = try await vm.downloadImages()
//                vm.images.append(image1)
//                
//                let image2 = try await vm.downloadImages()
//                vm.images.append(image2)
//                
//                let image3 = try await vm.downloadImages()
//                vm.images.append(image3)
//                
//                let image4 = try await vm.downloadImages()
//                vm.images.append(image4)
            }
        }
    }
}

#Preview {
    AsyncLet()
}

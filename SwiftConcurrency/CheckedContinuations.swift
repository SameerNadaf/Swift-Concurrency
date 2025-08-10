//
//  CheckedContinuations.swift
//  SwiftConcurrency
//
//  Created by Sameer  on 09/08/25.
//

import SwiftUI

class CheckedContinuationsManager {
    
    func downloadImage(url: URL) async throws -> UIImage {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let image = UIImage(data: data)
            guard let image else {
                throw URLError(.badServerResponse)
            }
            return image
        } catch {
            throw URLError(.badURL)
        }
    }
    
    func downloadImage2(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error {
                    print("Error: \(error)")
                    continuation.resume(throwing: URLError(.badServerResponse))
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
    }
    
    func getHeartImage(handler: @escaping(_ image: UIImage) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            handler(UIImage(systemName: "heart.fill")!)
        }
    }
    
    func getHeartWithAsync() async -> UIImage {
        return await withCheckedContinuation { continuation in
            getHeartImage { image in
                continuation.resume(returning: image)
            }
        }
    }
}

class CheckedContinuationsViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    private var manager = CheckedContinuationsManager()
    private let url: String = "https://picsum.photos/200"
    
    func loadImage() async {
        guard let url = URL(string: url) else { return }
        do {
            let returnedImage = try await manager.downloadImage(url: url)
            await MainActor.run {
                self.image = returnedImage
            }
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    func loadImage2() async {
        guard let url = URL(string: url) else { return }
        do {
            let data = try await manager.downloadImage2(url: url)
            if let returnedImage = UIImage(data: data) {
                await MainActor.run {
                    self.image = returnedImage
                }
            }
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    func loadHeartImage() {
        manager.getHeartImage {[weak self] image in
            self?.image = image
        }
    }
    
    func loadHeartAsync() async {
        let image = await manager.getHeartWithAsync()
        await MainActor.run {
            self.image = image
        }
    }
}

struct CheckedContinuations: View {
    
    @StateObject private var vm = CheckedContinuationsViewModel()
    
    var body: some View {
        ZStack {
            if let image = vm.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await vm.loadHeartAsync()
        }
    }
}

#Preview {
    CheckedContinuations()
}

//
//  DownloadImageAsync.swift
//  SwiftConcurrency
//
//  Created by Sameer  on 06/08/25.
//

import SwiftUI
import Combine

class DownloadImageAsyncDataManager {
    
    let url = URL(string: "https://picsum.photos/200")!
    
    func downloadWithEscaping(handler: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        URLSession.shared.dataTask(with: url) {[weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            handler(image, nil)
        }
        .resume()
    }
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }
    
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
    func downloadWithAsyncAwait() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
    
}

class DownloadImageAsyncViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    var manager = DownloadImageAsyncDataManager()
    private var cancellables = Set<AnyCancellable>()
    
    func loadImage() async {
        /*
//        manager.downloadWithEscaping { [weak self] image, error in
//            DispatchQueue.main.async {
//                self?.image = image
//            }
//        }
        
//        manager.downloadWithCombine()
//            .receive(on: DispatchQueue.main)
//            .sink { _ in
//                
//            } receiveValue: {[weak self] image in
//                self?.image = image
//            }
//            .store(in: &cancellables)
         
         */
        let image = try? await manager.downloadWithAsyncAwait()
        await MainActor.run {
            self.image = image
        }
    }
}

struct DownloadImageAsync: View {
    
    @StateObject var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .onAppear {
            Task {
                await viewModel.loadImage()
            }
        }
    }
}

#Preview {
    DownloadImageAsync()
}

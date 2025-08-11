//
//  AsyncStreamSwift.swift
//  SwiftConcurrency
//
//  Created by Sameer  on 11/08/25.
//

import SwiftUI

class AsyncStreamDataManager {
    
    func streamData(handler: @escaping(_ number: Int) -> ()) {
        let numbers: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        for number in numbers {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(number)) {
                handler(number)
            }
        }
    }
    
    func getAsyncStream() -> AsyncStream<Int> {
//        AsyncThrowingStream : hto handle errors
        
        AsyncStream(Int.self) {[weak self] continuation in
            self?.streamData { number in
                continuation.yield(number)
            }
        }
    }
}

class AsyncStreamViewModel: ObservableObject {
    @Published var number: Int = 0
    private let manager = AsyncStreamDataManager()
    
    func startStreaming() {
        Task {
            for await number in manager.getAsyncStream() {
                self.number = number
            }
        }
    }
}

struct AsyncStreamSwift: View {
    
    @StateObject private var vm = AsyncStreamViewModel()
    
    var body: some View {
        ZStack {
            Text("\(vm.number)")
        }
        .onAppear {
            vm.startStreaming()
        }
    }
}

#Preview {
    AsyncStreamSwift()
}

//
//  SendableProtocol.swift
//  SwiftConcurrency
//
//  Created by Sameer  on 10/08/25.
//

import SwiftUI

actor SendableActor {
    func sendData(data: SendableClass) {
        
    }
}

struct SendableStruct: Sendable {
    var data: String
}

final class SendableClass: @unchecked Sendable {
    private var data: String
    
    let lock = DispatchQueue(label: "com.example.lock")
    
    init(data: String) {
        self.data = data
    }
    
    func updateData(newData: String) {
        lock.async {
            self.data = newData
        }
    }
}

class SendableViewModel: ObservableObject {
    let manager = SendableActor()
    
    func updateData() async {
        let data = SendableClass(data: "Hello World")
        await manager.sendData(data: data)
    }
}

struct SendableProtocol: View {
    var body: some View {
        
    }
}

#Preview {
    SendableProtocol()
}

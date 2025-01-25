//
//  EventGenerator.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 1/18/25.
//

import Foundation
import SwiftUI

struct EventGeneratorView: View {
    @StateObject var viewModel = EventGeneratorViewModel()
    
    var body: some View {
        VStack {
            Button("Start", systemImage: "timer") {
                viewModel.getUser()
            }
            
            Label(viewModel.currentUser, systemImage: "person.fill")
        }
    }
}

@MainActor
class EventGeneratorViewModel : ObservableObject {
    @Published var currentUser: String = ""
    let generator: Generator<String> = Generator<String>(workItem: WorkItem { return "User #" })

    func getUser() {
        Task {
            await getUser()
        }
    }
    
    private func getUser() async {
        currentUser = "Phil"
        var i:Int = 1
        
        for await user in generator.getStream() {
            currentUser = user + String(i)
            i += 1
        }
        
        currentUser = "Terminated"
    }
}

enum GeneratorState : CustomStringConvertible {
    case initial(String)
    case processing(String)
    case finished
    
    var description : String {
        switch(self) {
        case .initial(let value):
            return "Initial: \(value)"
        case .processing(let value):
            return "\(value)"
        case .finished:
            return "Finished"
        }
    }
}

class StringGenerator {
    let workItem: WorkItem<String>
    var state: GeneratorState = .initial("Initial")
    
    init(workItem: WorkItem<String>) {
        self.workItem = workItem
    }
    
    func getStream() async -> AsyncStream<String> {
        AsyncStream<String> { continuation in
            Task {
                for i in 1..<6 {
                    let s = workItem.execute()
                    let event = String(s) + String(i)
                    self.state = .processing(event)
                    try await Task.sleep(nanoseconds: 1 * 2_000_000_000)
                    continuation.yield(event)
                }
                
                try await Task.sleep(nanoseconds: 1 * 5_000_000_000)
                continuation.yield("End")
                continuation.finish()
                self.state = .finished
            }
        }
    }
}

class Generator<T> {
    let workItem: WorkItem<T>
    
    init(workItem: WorkItem<T>) {
        self.workItem = workItem
    }
    
    func getStream() -> AsyncStream<T> {
        AsyncStream<T> { continuation in
            Task {
                for i in 1..<6 {
                    let s = workItem.execute()
                    try await Task.sleep(nanoseconds: UInt64(i * 5_000_000_000))
                    continuation.yield(s)
                }
                
                try await Task.sleep(nanoseconds: 1 * 5_000_000_000)
                continuation.finish()
            }
        }
    }
}

struct WorkItem<T> {
    let execute: () -> T
}

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
                Task {
                    await viewModel.getUser()
                }
            }
            
            Label(viewModel.currentUser, systemImage: "person.fill")
        }
    }
}

@MainActor
class EventGeneratorViewModel : ObservableObject {
    @Published var currentUser: String = ""
    let generator: StringGenerator = StringGenerator(workItem: WorkItem { return "User #" })
    
    func getUser() async {
        currentUser = "Phil"
        
        for await user in await generator.getStream() {
                currentUser = user
        }
        
        currentUser = "Terminated"
    }
}

class StringGenerator {
    let workItem: WorkItem<String>
    
    init(workItem: WorkItem<String>) {
        self.workItem = workItem
    }
    
    func getStream() async -> AsyncStream<String> {
        AsyncStream<String> { continuation in
            Task {
                for i in 1..<6 {
                    let s = workItem.execute()
                    let event = String(s) + String(i)
                    try await Task.sleep(nanoseconds: 1 * 5_000_000_000)
                    continuation.yield(event)
                }
                
                try await Task.sleep(nanoseconds: 1 * 5_000_000_000)
                continuation.yield("End")
                continuation.finish()
            }
        }
    }
}

struct WorkItem<T> {
    let execute: () -> T
}

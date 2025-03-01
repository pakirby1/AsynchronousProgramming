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
    let generator: Generator<User>?
    let service: UserService?
    
    init() {
        self.service = UserService()
        self.generator = Generator<User>()
        self.generator?.workItem = WorkItem<User> { [weak self] in
            guard let self else { return [] }
            return self.service?.getUsers() ?? []
        }
    }
    
    func getUser() {
        Task {
            await getUser()
        }
    }
    
    private func getUser() async {
        currentUser = "No User"
        var i:Int = 1
        
        guard let gen = generator else { return }
        
        for await user in gen.getStream() {
            currentUser = "User #\(String(i)): \(user.details.firstName)"
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

class Generator<T> {
    var workItem: WorkItem<T>? = nil
    
    init() {}
    
    init(workItem: WorkItem<T>) {
        self.workItem = workItem
    }
    
    func getStream() -> AsyncStream<T> {
        AsyncStream<T> { continuation in
            Task {
                guard let wi = workItem else {
                    continuation.finish()
                    return
                }
                
                guard let exec = wi.execute else {
                    continuation.finish()
                    return
                }
                
                let users:[T] = exec() // returns [User]
                var i = 1
                
                for user in users {
                    try await Task.sleep(nanoseconds: UInt64(i * 2_000_000_000))
                    continuation.yield(user)   // User
                    i += 1
                }
                
                try await Task.sleep(nanoseconds: 1 * 5_000_000_000)
                continuation.finish()
            }
        }
    }
}

class WorkItem<T> {
    var execute: (() -> [T])?
    
    init(execute: (() -> [T])? = nil) {
        self.execute = execute
    }
}

class UserWorkItem {
    let execute: (() -> [User])? = nil
    
    init() {
        
    }
    
    func run() -> [User] {
        guard let exec = execute else { return [] }
        
        let result: [User] = exec()
        
        return result
    }
}

enum MyError : Error {}


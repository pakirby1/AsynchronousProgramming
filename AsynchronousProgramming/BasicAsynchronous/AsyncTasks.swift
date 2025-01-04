//
//  AsyncTasks.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 12/27/24.
//

import Foundation

class AsyncTasks {
    var task: Task<Int, Never>?
    let id: Int
    
    init(id: Int) {
        self.id = id
    }
    
    func initTask() {
        task = Task {
            do {
                Log("AsyncTasks.initTask()", "before try await")    // 7
                Log("AsyncTasks.initTask()", "try await Task.sleep(nanoseconds: 5_000_000)")
                try await Task.sleep(nanoseconds: 5_000_000)
                try? await Task.sleep(for: .milliseconds(10))
                Log("AsyncTasks.initTask()", "after try await")     // 8
                return id
            } catch {
                print(error)
            }
            
            return -1
        }
    }
}

//
//  Tasks.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 1/23/25.
//

import Foundation
import SwiftUI

struct TaskView : View {
    var body: some View {
        VStack {
            ThreeTasksView()
            AsyncLetTasks()
        }
    }
}

struct ThreeTasksView: View {
    @State var title: String = "Start Three Tasks In Parallel"
    
    var body: some View {
        Button(title) {
            print(title)
            Task {
                print("running Task 1")
                try await Task.sleep(nanoseconds: 3 * 2_000_000_000)
                print("Task 1 ended.")
            }

            Task {
                print("running Task 2")
                try await Task.sleep(nanoseconds: 3 * 2_000_000_000)
                print("Task 2 ended.")
            }

            Task {
                print("running Task 3")
                try await Task.sleep(nanoseconds: 3 * 2_000_000_000)
                print("Task 3 ended.")
                
            }
        }
    }
}

struct AsyncLetTasks: View {
    @State var title: String = "Use async let to start tasks in parallel"
    
    var body: some View {
        Button(title) {
            print(title)
            
            Task {
                async let firstTask = await runTask(id: "1")
                async let secondTask = await runTask(id: "2")
                async let thirdTask = await runTask(id: "3")
                let images = await [firstTask, secondTask, thirdTask]
            }
        }
    }
    
    func runTask(id: String) async {
        Task {
            print("running \(id)")
            try await Task.sleep(nanoseconds: 3 * 2_000_000_000)
            print("Task \(id) ended.")
        }
    }
}

struct TaskGroupView: View {
    @State var title: String = "Use a task group to start tasks in parallel"
    
    var body: some View {
        Button(title) {
            print(title)
        }
    }
}

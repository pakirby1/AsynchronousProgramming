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
//            TaskGroupView()
            TaskGroupViewWithReturn()
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
    @State var results: [String] = []
    let ids: [Int] = [4, 15, 17, 2, 3]
    
    var body: some View {
        Button(title) {
            print(title)
            Task {
                await test()
            }
        }
        
        List(ids, id: \.self) { initial in
            Text(String(initial))
        }
        
        List(results, id: \.self) { result in
            Text(result)
        }
    }
    
    func test() async {
        return await withTaskGroup(of: Void.self) { group in
            let ids: [Int] = [4, 15, 17, 2, 3]
            
            // adding tasks to the group
            for id in ids {
                group.addTask {
                    return await self.runTask(id: id)
                }
            }
        }
    }
    
    func runTask(id: Int) async {
        Task {
            print("running \(id)")
            
            // Simulate a network call
            try await Task.sleep(nanoseconds: UInt64(id * 1_000_000_000))
            print("Task \(id) ended.")
        }
    }
}

struct TaskGroupViewWithReturn: View {
    @State var title: String = "Use a task group to start tasks in parallel"
    @State var results: [String] = []
    let ids: [Int] = [4, 15, 17, 2, 3]
    @State var currentTime: Date = Date.now
    
    var body: some View {
        Button(title) {
            print(title)
            Task {
                results = await test(ids: ids)
            }
        }
        
        List(ids, id: \.self) { initial in
            Text(String(initial))
        }
        
        Text(Date.now.description)
        
        List(results, id: \.self) { result in
            Text(result)
        }
        
        Text(Date.now.description)
    }
    
    func test(ids: [Int]) async -> [String] {
        return await withTaskGroup(of: String.self) { group in
            var results = [String]()
            
            // adding tasks to the group
            for id in ids {
                group.addTask {
                    print("running \(id)")
                    return await self.runTask(id: id)
                }
            }
            
            // await until all tasks complete
            for await str in group {
                results.append(str)
            }
            
            return results
        }
    }
    
    func runTask(id: Int) async -> String {
        do {
            // Simulate a network call
            try await Task.sleep(nanoseconds: UInt64(id * 1_000_000_000))
            return "Task \(id) ended. \(Date.now)"
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }
}

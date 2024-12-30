//
//  File.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 12/22/24.
//

import Foundation

// Tests basic async/await and using Tasks
/*
 
 1    2024-12-28 01:47:22 +0000 BasicAsynchronous.mainThreadFunc => before calling BasicAsynchronous.doSomething(id: 1)
 2    2024-12-28 01:47:22 +0000 BasicAsynchronous.mainThreadFunc => after calling await BasicAsynchronous.doSomething(id: 1)
 3    2024-12-28 01:47:22 +0000 BasicAsynchronous.mainThreadFunc => before await doSomething(id: 1)
 4    2024-12-28 01:47:22 +0000 BasicAsynchronous.mainThreadFunc => await doSomething(id: 1)
 {
     5    2024-12-28 01:47:22 +0000 BasicAsynchronous.doSomething(id: 1) => start BasicAsynchronous.doSomething(id: 1)
     6    2024-12-28 01:47:22 +0000 BasicAsynchronous.doSomething(id: 1) => await executeTask()
     {
         7    2024-12-28 01:47:22 +0000 BasicAsynchronous.doSomething(id: 1).executeTask() => start
         8    2024-12-28 01:47:22 +0000 BasicAsynchronous.doSomething(id: 1).executeTask() => before await t.value
         9    2024-12-28 01:47:22 +0000 BasicAsynchronous.doSomething(id: 1) => await t.value
         {
             10    2024-12-28 01:47:22 +0000 AsyncTasks.initTask() => before try await
             11    2024-12-28 01:47:22 +0000 AsyncTasks.initTask() => try await Task.sleep(nanoseconds: 5_000_000)
             12    2024-12-28 01:47:22 +0000 AsyncTasks.initTask() => after try await
         }
         13    2024-12-28 01:47:22 +0000 BasicAsynchronous.doSomething(id: 1).executeTask() => value from task: 1
         14    2024-12-28 01:47:22 +0000 BasicAsynchronous.doSomething(id: 1).executeTask() => end
     }
     15    2024-12-28 01:47:22 +0000 BasicAsynchronous.doSomething(id: 1) => end BasicAsynchronous.doSomething(id: 1)
 }
 16    2024-12-28 01:47:22 +0000 BasicAsynchronous.mainThreadFunc => after await doSomething(id: 1)
 
 await chain:
    await doSomething(id: i) {
        await executeTask() {
            await t.value {
                try await Task.sleep(nanoseconds: 5_000_000) {}
            }
        }
    }
 */
class BasicAsynchronous {
    func doSomething(id: Int) async {
        func executeTask() async {
            Log("BasicAsynchronous.doSomething(id: \(id)).executeTask()", "start") // 5
            let at: AsyncTasks = AsyncTasks(id: id)
            at.initTask()
            
            guard let t = at.task else {
                Log("BasicAsynchronous.doSomething(id: \(id)).executeTask()", "at.task is nil")
                return
            }
                    
            Log("BasicAsynchronous.doSomething(id: \(id)).executeTask()", "before await t.value") // 6
            Log("BasicAsynchronous.doSomething(id: \(id))", "await t.value") // 4
            let x: Int = await t.value;
            Log("BasicAsynchronous.doSomething(id: \(id)).executeTask()", "value from task: \(x)")  // 9
            Log("BasicAsynchronous.doSomething(id: \(id)).executeTask()", "end")    // 10
        }
        
        Log("BasicAsynchronous.doSomething(id: \(id))", "start BasicAsynchronous.doSomething(id: \(id))") // 4
        Log("BasicAsynchronous.doSomething(id: \(id))", "await executeTask()") // 4
        await executeTask()
        
        Log("BasicAsynchronous.doSomething(id: \(id))", "end BasicAsynchronous.doSomething(id: \(id))") // 11
    }
    
    func mainThreadFunc() {
        for i in 1...1 {
            Log("BasicAsynchronous.mainThreadFunc", "before calling BasicAsynchronous.doSomething(id: \(i))")   // 1

            // start these two tasks in parallel (because Tasks execute concurrently
            doSomethingTask(id: i)
//            doSomethingTask(id: i + 1)
            
            // Executes concurrently with the Task above
            Log("BasicAsynchronous.mainThreadFunc", "after calling await BasicAsynchronous.doSomething(id: \(i))")  // 2
        }
    }
}

extension BasicAsynchronous {
    func doSomethingTask(id: Int) {
        Task {
            Log("BasicAsynchronous.mainThreadFunc", "before await doSomething(id: \(id))")   // 3
            Log("BasicAsynchronous.mainThreadFunc", "await doSomething(id: \(id))")
            await doSomething(id: id)
            Log("BasicAsynchronous.mainThreadFunc", "after await doSomething(id: \(id))")    // 12
        }
    }
}
func Log(_ source: String, _ label: String) {
    let date = Date()
    
    print("\(date) \(source) => \(label)")
}

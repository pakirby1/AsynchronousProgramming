//
//  Stream.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 2/26/25.
//

import Foundation

class Stream<T> : TaskCancellable {
    internal var task: Task<(), Never>?
    let stream: AsyncStream<T>
    private let continuation: AsyncStream<T>.Continuation
    let handler: () -> T
    var running: Bool = false
    
    init(work: @escaping () -> T) {
        let (stream, continuation) = AsyncStream<T>.makeStream(of: T.self)
        self.stream = stream
        self.continuation = continuation
        
        // Setup the termination method when a Task is cancelled (task.cancel())
        self.continuation.onTermination = { _ in
            print("continuation.onTermination")
        }
        self.handler = work
    }
    
    deinit {
        continuation.finish()
        print("NewStream.deinit")
    }
    
    func start() {
        running = true
        
        func buildTask() -> Task<(), Never>? {
            return Task<(), Never> {
                print("running buildTask()")

                while (running) {
                    print("gettting data")
                    try? await Task.sleep(for: .milliseconds(5000))
                    try? Task.checkCancellation()
                    let value = handler()
                    
                    self.continuation.yield(value)
                }
            }
        }
        
        self.task = buildTask()
    }
    
    /*
     stop button tapped
     NewStream.stop() started
     continuation.onTermination
     NewStream.task cancelled
     NewStream.task deinitialized
     NewStream.stop() ended
     */
    func stop() {
        print("NewStream.stop() started")
        cancelStream()
        
        print("NewStream.stop() ended")
    }
    
    private func cancelStream() {
        // update running
        self.running = false
        print("self.running = \(self.running)")
        
        // finish the continuation
        print("before continuation.finish()")
        continuation.finish()
        print("continuation.finish() executed")

        // cancel and set task to nil, which should call the onTermination closure on the continuation
        cancelTask(label: "NewStream.task")
    }
}

/*
class Stream<T> : TaskCancellable {
    var task: Task<(), Never>?
    var running: Bool
    var handler: (() -> T)?
    var continuation: AsyncStream<T>.Continuation?
    
    init(handler: (() -> T)? = nil) {
        self.handler = handler
        running = false
    }
    
    func start() -> AsyncStream<T> {
        func buildTask(cont: AsyncStream<T>.Continuation) -> Task<(), Never>? {
            self.continuation = cont
            
            return Task<(), Never> {
                print("running startTask()")

                while (running) {
                    print("gettting data")
                    try? await Task.sleep(for: .milliseconds(2000))
                    try? Task.checkCancellation()
                    guard let h = handler else { return }
                    let value = h()
                    
                    cont.yield(value)
                }
            }
        }
        
        running = true
        
        return AsyncStream { cont in
            self.task = buildTask(cont: cont)
        }
    }

    func stop() {
        print("Stream<T>.stop() started")
        // cancel and set task to nil
        cancelTask(label: "Stream<T>.task")
        
        // update the running state
        running = false
        
        // finish the continuation
        guard let cont = continuation else { return }
        cont.finish()
        print("Stream<T>.stop() ended")
    }
}
*/

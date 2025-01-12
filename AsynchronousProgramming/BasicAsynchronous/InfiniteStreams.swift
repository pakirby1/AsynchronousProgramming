//
//  InfiniteStreams.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 1/4/25.
//

import Foundation
import SwiftUI
/*
 Currently, the for await in loop doesn't run until all elements in a stream have been sent
 to the stream and a continuation.finished() call has been made
 */

let stream = AsyncStream<Int>(Int.self,
                                   bufferingPolicy: .bufferingNewest(5)) { continuation in
         Task.detached {
             for _ in 0..<100 {
                 try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
                 continuation.yield(Int.random(in: 1...10))
             }
             continuation.finish()
         }
     }

class InfiniteStream {
    // Will generate events until the parent task is completed
    let closureA:AsyncStream<AsyncEvent<Int>> = AsyncStream<AsyncEvent<Int>>{
        try? await Task.sleep(nanoseconds: 5_000_000)
        let value = Int.random(in: 0..<Int.max)
        return AsyncEvent<Int>(value: value)
    }
    
    
    let closureB:AsyncStream<AsyncEvent<Int>> = AsyncStream<AsyncEvent<Int>>{ continuation in
        // Only one value will be yielded, because the Task goes out of scop which cancels the
        // event generation
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000)
            let val = Int.random(in: 0..<Int.max)
            continuation.yield(AsyncEvent<Int>(value: val))
            continuation.finish()
        }
    }
    
    /*
    let closureB:AsyncStream<Int> = AsyncStream<Int>{ continuation in
        Task {
            for i in 1...10 {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                continuation.yield(Int.random(in: 0..<Int.max))
            }
        }
    }
    */
    
    func subscribe() async -> AsyncStream<AsyncEvent<Int>> {
//        return closureC
        return closureA
//        return closureB
    }
}

struct InfiniteStreamView: View {
    @State var viewModel = InfiniteStream()
    
    var body: some View {
        Button("Start Infinite Stream") {
            Task {
                let events = await viewModel.subscribe()
                for await event in events {
                    print(event)
                }
            }
        }
    }
}

struct AsyncEvent<T> {
    let value: T
    let time = Date()
}

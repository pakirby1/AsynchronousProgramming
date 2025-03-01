//
//  AsyncManager.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 2/21/25.
//

import Foundation

/*
 https://forums.swift.org/t/pitch-convenience-async-throwing-stream-makestream-methods/61030/32
 */
public actor AsyncStreamManager<T: Sendable> {
    typealias ContinuationMap = [UUID: AsyncStream<T>.Continuation]
    
    private var continuations: ContinuationMap
    
    public init() {
        self.continuations = [:]
    }
    
    private func insert(continuation: AsyncStream<T>.Continuation) {
        let uuid = UUID()
        continuations[uuid] = continuation
    }
    
    public func send(_ value: T) {
        continuations.values.forEach { continuation in
            continuation.yield(value)
        }
    }
    
    public func finish(_ value: T) {
        send(value)
        continuations.values.forEach { continuation in
            continuation.finish()
        }
        
        continuations.removeAll()
    }
    
    public func makeStream() -> AsyncStream<T> {
        let stream = AsyncStream { continuation in
            insert(continuation: continuation)
        }
        
        return stream
    }
    
    public func makeStream(with task: Task<(), Never>) -> AsyncStream<T> {
        let stream = AsyncStream { continuation in
            insert(continuation: continuation)
            task
        }
        
        return stream
    }
}

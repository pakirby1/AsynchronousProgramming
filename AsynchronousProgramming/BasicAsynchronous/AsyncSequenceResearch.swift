//
//  AsyncSequence.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 12/28/24.
//

import Foundation

class AsyncSequenceResearch {
//    // Create and respond to events from an AsyncSequence
//    var AsyncSequence<TestEvent<Int>>: AsyncSequence<TestEvent<Int>> {
//        
//    }
    //

}

enum AsyncStreamStatus<T> {
    case downloading(Double)
    case event(DownloadEvent)
    case finished
}

class AsyncStreamGenerator {
    var id = 1
    
    let stream = AsyncStream<Int>(Int.self,
                                  bufferingPolicy: .bufferingNewest(5)) { continuation in
        Task.detached {
            for _ in 0..<100 {
                try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
                continuation.yield(Int.random(in: 1...10))
            }
            continuation.finish()
        }
    }

    func download() -> AsyncStream<AsyncStreamStatus<Int>> {
        return AsyncStream { continuation in
                self.generateData(completion: { result in
                    switch result {
                    case .success(let data):    // Result<DownloadEvent, Error>
                        continuation.yield(.event(data))
                    case .failure(let _):
                        continuation.yield(.finished)
                        continuation.finish()
                    }
                })
        }
    }
    
    func generateData(completion: (Result<DownloadEvent, Error>) -> Void) {
        let items: Int = 20
        let step: Int = 100 / items
        
        while (id < (items + 1)) {
            let progress: Int = id * step // 0->20->40->60->80->100
        
            let r: Result<DownloadEvent, Error> = .success(DownloadEvent(progress: progress, event: TestEvent(value: id)))
            completion(r)
            id += 1
        }
        
        completion(.failure(AsyncStreamGeneratorError()))
    }
}

class AsyncStreamGeneratorError : Error {
    
}

class AsyncStreamConsumer {
    let generator = AsyncStreamGenerator()
    
    func consume() {
        Task.detached {
            for try await event in self.generator.download() {
                print(event)
            }
        }
    }
}


struct TestEvent<T> {
    let value: T
}

struct DownloadEvent {
    let progress: Int
    let event: TestEvent<Int>
}

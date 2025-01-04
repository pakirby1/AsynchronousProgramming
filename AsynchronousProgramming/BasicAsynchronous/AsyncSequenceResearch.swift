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
    var continuation: AsyncStream<AsyncStreamStatus<Int>>.Continuation? = nil
    
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

    func generate() -> AsyncStream<AsyncStreamStatus<Int>> {
        return AsyncStream { continuation in
                self.generateData(completion: { result in
                    switch result {
                    case .success(let data):    // Result<DownloadEvent, Error>
                        continuation.yield(.event(data))
                    case .failure( _):
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
        
            if (id != 7) {
                let r: Result<DownloadEvent, Error> = .success(DownloadEvent(progress: progress, event: TestEvent(value: id)))
                completion(r)
            } else {
                let e: Result<DownloadEvent, Error> = .failure(AsyncStreamGeneratorError())
                completion(e)
            }
            
            id += 1
        }
        
        completion(.failure(AsyncStreamGeneratorError()))
    }
    
    //New Code
    func downloadEvents() async -> AsyncStream<AsyncStreamStatus<Int>> {
        AsyncStream<AsyncStreamStatus<Int>> { continuation in
            Task {
                self.continuation = continuation
                
                let source = EventGeneratorSource(continuation: continuation)
                source.start()
            }
        }
    }
    
    func stopEvents() {
        continuation?.yield(.finished)
        continuation?.finish()
    }
}

final class EventGeneratorSource {
    // ...
    let continuation: AsyncStream<AsyncStreamStatus<Int>>.Continuation
    var id: Int = 0
    
    init(continuation: AsyncStream<AsyncStreamStatus<Int>>.Continuation) {
        self.continuation = continuation
    }
    
    func start() {
        // Generate Events
        func generateData(completion: (Result<DownloadEvent, Error>) -> Void) {
            let items: Int = 20
            let step: Int = 100 / items
            
            while (id < (items + 1)) {
                let progress: Int = id * step // 0->20->40->60->80->100
            
                if (id != 7) {
                    let r: Result<DownloadEvent, Error> = .success(DownloadEvent(progress: progress, event: TestEvent(value: id)))
                    completion(r)
                } else {
                    let e: Result<DownloadEvent, Error> = .failure(AsyncStreamGeneratorError())
                    completion(e)
                }
                
                id += 1
            }
            
            completion(.failure(AsyncStreamGeneratorError()))
        }

        generateData(completion: { result in
            switch result {
            case .success(let data):    // Result<DownloadEvent, Error>
                continuation.yield(.event(data))
            case .failure( _):
                continuation.yield(.finished)
                continuation.finish()
            }
        })
    }
    
    func stop() {
        // stop the continuation
        continuation.yield(.finished)
        continuation.finish()
    }
}

class AsyncStreamGeneratorError : Error {
    
}

class AsyncStreamConsumer {
    let generator = AsyncStreamGenerator()
    
    func consume() {
        Task.detached {
            for try await event in self.generator.generate() {
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

/*
 https://www.emergetools.com/blog/posts/swift-async-await-the-full-toolkit#async-sequence
 
 func trackDownload() -> AsyncStream<Double> {
     AsyncStream<Double> { continuation in
         let delegate = DownloadProgressDelegate(continuation: continuation)
         URLSession.shared.delegate = progressDelegate
     }
 }

 final class DownloadProgressDelegate: NSObject, URLSessionDownloadDelegate {
     // ...
     let continuation: AsyncStream<Double>.Continuation

     func urlSession(_ session: URLSession,
                     downloadTask: URLSessionDownloadTask,
                     didWriteData bytesWritten: Int64,
                     totalBytesWritten: Int64,
                     totalBytesExpectedToWrite: Int64) {
         let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
         continuation.yield(progress * 100)
     }

 }

 */

class AsyncViewModel {
    let downloadAPI: DownloadAPI
    
    init(downloadAPI: DownloadAPI) {
        self.downloadAPI = downloadAPI
    }
    
    func performDownload() async -> AsyncStream<Double> {
        AsyncStream { continuation in
            Task {
                await downloadAPI.startDownload { percentage in
                    continuation.yield(percentage)
                }
                continuation.finish()
            }
        }
    }
}

class DownloadAPI {
    func startDownload(completion: @escaping (Double) -> Void) async {
        for i in 1...5 {
            do {
//                try await Task.sleep(nanoseconds: 10_000_000)
                try? await Task.sleep(for: .milliseconds(10))
                completion(Double(i * 20))
            } catch {
                completion(0)
            }
        }
    }
}


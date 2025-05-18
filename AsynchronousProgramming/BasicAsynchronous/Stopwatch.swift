//
//  Stopwatch.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 1/11/25.
//

import Foundation
import SwiftUI

struct StopwatchView : View {
    @State var viewModel = StopwatchViewModel()
    
    var body: some View {
        VStack {
            Button("Start Stopwatch") {
                Task {
                    await viewModel.start()
                }
            }
            
            Button("Stop Stopwatch") {
                Task {
                    await viewModel.stop()
                }
            }
            
            Divider()
            Label("Current time: \(viewModel.currentTime)", systemImage: "timer")
        }
    }
}
@Observable
@MainActor
class StopwatchViewModel {
    var currentTime: Date = Date()
    private let generator = EventGenerator()
    
    func start() async {
        await generator.start()
        
        for await event in generator.eventStream {
            currentTime = event
        }
    }
    
    func stop() async {
        await generator.stop()
    }
}

class EventGenerator {
    private var isRunning: Bool = false
    
    lazy var eventStream: AsyncStream<Date> = {
        AsyncStream { continuation in
            Task {
                while(isRunning) {
                    do {
                        try await Task.sleep(nanoseconds: 5_000_000)
                    }
                    catch{
                        print(error)
                    }
                    
                    continuation.yield(Date.now)
                }
            }
        }
    }()
    
    func start() async {
        isRunning = true
    }
    
    func stop() async {
        isRunning = false
    }
}

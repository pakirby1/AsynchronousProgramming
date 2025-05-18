//
//  BasicView.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 3/6/25.
//

import Foundation
import SwiftUI

struct BasicView : View {
    @State var viewModel = MagicButtonViewModel()
    
    var body: some View {
        Text("BasicView")
        Text(viewModel.output)
        
        HStack {
            CustomButtonView(text: "Start", color: .green) {
                print("Start button tapped")
                viewModel.start()
            }
            
            CustomButtonView(text: "Stop", color: .red) {
                print("Stop button tapped")
                viewModel.stop()
            }
        }
    }
}

@Observable
@MainActor class MagicButtonViewModel {
    var output: String = "🙈"
    private var subscription: Task<(), Error>!
    
    init() {
        print("init MagicButtonViewModel")
    }
    
    deinit {
        print("Deinit MagicButtonViewModel")
    }
    
    public func start() {
        func present(_ result: String) async throws {
            output = result
            
            try await Task.sleep(nanoseconds: 1_000_000_000)
        }
        
        subscription = Task {
            for await number in TickerAsyncSequenceFactory().makeAsyncSequence() {
                try await present("⏰ \(number) ⏰")
                print("number: \(number)")
            }
        }
    }
    
    public func stop() {
        guard let sub = subscription else { return }
        
        sub.cancel()
        print("cancelled task")
        subscription = nil
    }
}

public class TickerAsyncSequenceFactory {
    init() {
        print("init TickerAsyncSequenceFactory")
    }

    deinit {
        print("Deinit TickerAsyncSequenceFactory")
    }
    
    func makeAsyncSequence() -> AsyncStream<Int> {
        print("makeAsyncSequence()")
        return AsyncStream(Int.self) { continuation in
            let ticker = Ticker()
            
            ticker.tick = { continuation.yield($0) }
            
            continuation.onTermination = { _ in
                ticker.stop()
                print("Ticker stopped")
            }
            
            ticker.start()
            print("Ticker started")
        }
    }
}

public class Ticker {
    init() {
        print("init Ticker")
    }
    
    deinit {
        print("Deinit Ticker")
    }
    
    public var tick: ((Int) -> ())?
    public private(set) var counter: Int = 0
    private var timer: Timer?
    
    func start() {
        counter = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let `self` = self else { return }
            self.tick?(self.counter)
            self.counter += 1
        }
    }
    
    func stop() {
        timer?.invalidate()
    }
}


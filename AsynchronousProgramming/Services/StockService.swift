//
//  DoubleStreamService.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 2/26/25.
//

import Foundation

/*
let stream = NewStream() {
    return Double.random(in: 10.0 ..< 20.0)
}
*/
class StockService {
    let dataService = JSONDataService()
    private(set) var stocks: [Stock] = []
    private var currentIndex: Int = 0
    
    lazy var stream = Stream<Stock?>() { [weak self] in
        guard let self = self else {
            return nil
        }
        
        let len = stocks.count
        
        if self.currentIndex < len {
            let stock = stocks[self.currentIndex]
            self.currentIndex += 1
            return stock
        }
        
        print("No more data to send.  ending stream (returning nil).")
        return nil
    }
    
    func start() -> AsyncStream<Stock?> {
        Task {
            // Get the array of stocks
            self.stocks = await dataService.getStocks()
            stream.start()
        }
        
        return stream.stream
    }
    
    func stop() {
        stream.stop()
    }
}

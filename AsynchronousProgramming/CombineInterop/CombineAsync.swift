//
//  CombineAsync.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 1/3/25.
//

import Foundation
import Combine
import SwiftUI

class CombineViewModel {
    let publisher: Just<Int> = Just(125)
    
    var stream: AnyPublisher<Int, Never> {
        get { return publisher.eraseToAnyPublisher() }
    }
    
    func test_async() async -> Int {
        do {
            let x: Int = try await stream.async()
            
            return x
        } catch {
            print(error)
        }
        
        return -1
    }
    
    func test_async_new() async -> String {
        do {
            let stringStream: Just<String> = publisher.map{ "\($0)" }
            let x: String = try await stringStream.eraseToAnyPublisher().async()
            return x
        } catch {
            print(error)
        }
        
        return ""
    }
}

struct CombineView: View {
    let viewModel: CombineViewModel = CombineViewModel()
    
    var body: some View {
        Button("Test Combine") {
            Task {
                let x = await viewModel.test_async_new()
                print("x: \(x)")
            }
        }
    }
}

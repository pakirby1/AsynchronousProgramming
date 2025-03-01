//
//  TaskCancellable.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 2/25/25.
//

import Foundation

protocol TaskCancellable : AnyObject {
    associatedtype Element
    var task: Task<Element, Never>? { get set }
    func cancelTask(label: String)
}

extension TaskCancellable {
    func cancelTask(label: String) {
        guard let t = self.task else { return }
        t.cancel()
        self.task = nil
        print("\(label) cancelled")
        print("\(label) deinitialized")
    }
}

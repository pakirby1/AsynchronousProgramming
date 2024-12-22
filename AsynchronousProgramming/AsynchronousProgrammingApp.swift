//
//  AsynchronousProgrammingApp.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 12/22/24.
//

import SwiftUI

@main
struct AsynchronousProgrammingApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

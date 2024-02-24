//
//  notifications_core_dataApp.swift
//  notifications-core-data
//
//  Created by Robert Brennan on 2/24/24.
//

import SwiftUI

@main
struct notifications_core_dataApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

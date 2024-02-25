//
//  ContentView.swift
//  notifications-core-data
//
//  Created by Robert Brennan on 2/24/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            NavigationLink {
                NotificationsView()
            } label: {
                Text("Open notifications view")
            }
            .padding()
        }
    }
}

//#Preview {
//    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}

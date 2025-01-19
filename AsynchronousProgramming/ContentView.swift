//
//  ContentView.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 12/22/24.
//

import SwiftUI
import CoreData

struct TimestampListView : View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .onAppear() {
//                BasicAsynchronous().mainThreadFunc()
//                AsyncStreamConsumer().consume()
            }
            Text("Select an item")
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
//        TimestampListView()
//        AsyncView()
//        CombineView()
//        InfiniteStreamView()
//        StopwatchView()
        EventGeneratorView()
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

struct AsyncView: View {
    @State var generator = AsyncStreamGenerator()
    @State private var currentValue = 0
    @State var viewModel = AsyncViewModel(downloadAPI: DownloadAPI())
    
    var body: some View {
        VStack {
            Button("Start") {
                Task {
                    // start the stream
                    let events = await generator.downloadEvents()
                    print("Events")
                    
                    for await event in events {
                        print(event)
                    }
                }
            }
            
            Button("Stop") {
                // end the stream
            }
            
            Button("AsyncViewModel") {
                Task {
                    let events = await viewModel.performDownload()
                    
                    for await event in events {
                        print(event)
                    }
                }
            }
        }
    }
}

//
//  TravelDiaryApp.swift
//  TravelDiary
//
//  Created by Gianni Tumedei on 07/05/25.
//

import SwiftData
import SwiftUI

@main
struct MyBookShelfApp: App {
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container2)
        //.modelContainer(for: SavedBook.self)

        //.modelContainer(container)
    }

    var container2: ModelContainer {
        #if DEBUG
        return PreviewData2.makeModelContainer()
        #else
        return try! ModelContainer(for: SavedBook.self)
        #endif
    }
    
    var container: ModelContainer {
        #if DEBUG
        return PreviewData.makeModelContainer()
        #else
        return try! ModelContainer(for: Book.self)
        #endif
    }
    
    
    
    
    /*var body: some Scene {
        WindowGroup {
            ContentView()
                //.environment(\.font, .custom("Baskerville-Italic", size: 16)) , non funziona ma è da impostare

        }
        .modelContainer(for: [Book.self])
     }*/
    
}






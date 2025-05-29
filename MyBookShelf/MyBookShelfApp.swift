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
                //.environment(\.font, .custom("Baskerville-Italic", size: 16)) , non funziona ma è da impostare

        }
        .modelContainer(for: [Book.self])
    }
}

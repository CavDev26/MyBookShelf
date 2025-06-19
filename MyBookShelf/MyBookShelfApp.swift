//
//  TravelDiaryApp.swift
//  TravelDiary
//
//  Created by Gianni Tumedei on 07/05/25.
//

import SwiftData
import SwiftUI
import Firebase

@main
struct MyBookShelfApp: App {
    @StateObject private var authManager = AuthManager() // 👈

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            StartupView()
                .environmentObject(authManager)
        }
        .modelContainer(for: SavedBook.self)
    }
}






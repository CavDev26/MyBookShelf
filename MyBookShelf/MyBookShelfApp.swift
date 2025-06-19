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
    @AppStorage("useSystemColorScheme") var useSystemColorScheme: Bool = true
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @StateObject private var authManager = AuthManager() // 👈

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            StartupView()
                .environmentObject(authManager)
                .preferredColorScheme(
                    useSystemColorScheme ? nil : (isDarkMode ? .dark : .light)
                )
        }
        .modelContainer(for: [SavedBook.self, Shelf.self])
    }
}






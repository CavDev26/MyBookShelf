//
//  WatchMyBookShelfApp.swift
//  WatchMyBookShelf Watch App
//
//  Created by Lorenzo Cavallucci on 21/06/25.
//

import SwiftUI

@main
struct WatchMyBookShelf_Watch_AppApp: App {
    @StateObject var watchSessionManager = WatchSessionManager.shared
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                WatchHomeView()
            }
        }
    }
}

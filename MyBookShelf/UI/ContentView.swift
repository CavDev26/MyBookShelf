//
//  ContentView.swift
//  TravelDiary
//
//  Created by Gianni Tumedei on 07/05/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BookListView()
                .tabItem { Label("Home", systemImage: "house") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "") }

        }
    }
}

#Preview {
    ContentView().modelContainer(PreviewData.makeModelContainer())
}

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DiscoverView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            MyBooksView()
                .tabItem { Label("My Books", systemImage: "books.vertical") }
            AddBooksView()
                .tabItem { Label("Add", systemImage: "plus") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}

#Preview {
    ContentView().modelContainer(PreviewData.makeModelContainer())
}

import SwiftUI

struct ContentView: View {
    var body: some View {        
        TabView {
            BookListView()
                .tabItem { Label("My Books", systemImage: "books.vertical") }
            AddBooksView()
                .tabItem { Label("Add", systemImage: "plus") }
            DiscoverView()
                .tabItem { Label("Discover", systemImage: "safari") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}

#Preview {
    ContentView().modelContainer(PreviewData.makeModelContainer())
}

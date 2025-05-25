import SwiftUI

struct ContentView: View {
    var body: some View {
            TabView {
                BookListView()
                    .background(Color(.blue))
                    .tabItem { Label("My Books", systemImage: "books.vertical") }
                AddBooksView()
                    .background(Color(.blue))
                    .tabItem { Label("Add", systemImage: "plus") }
                DiscoverView()
                    .background(Color(.blue))
                    .tabItem { Label("Discover", systemImage: "safari") }
                ProfileView()
                    .background(Color(.blue))
                    .tabItem { Label("Profile", systemImage: "person.crop.circle") }

            }
    }
}

#Preview {
    ContentView().modelContainer(PreviewData.makeModelContainer())
}

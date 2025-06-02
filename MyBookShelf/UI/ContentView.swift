import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? .black : .white)
                .ignoresSafeArea()
            TabView {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house.fill") }

                MyBooksView2()
                    .tabItem { Label("My Books", systemImage: "books.vertical") }

                AddBooksView()
                    .tabItem { Label("Add", systemImage: "plus") }

                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.crop.circle") }
            }.onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(
                    white: colorScheme == .dark ? 0.05 : 1.0,
                    alpha: 0.9
                )
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

#Preview {
    ContentView().modelContainer(PreviewData.makeModelContainer())
}

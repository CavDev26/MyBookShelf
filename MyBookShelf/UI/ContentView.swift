import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            TabView (selection: $selectedTab){
                HomeView(selectedTab: $selectedTab)
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(0)
                
                MyBooksView2(selectedTab: $selectedTab)
                    .tabItem { Label("My Books", systemImage: "books.vertical") }
                    .tag(1)
                
                AddBooksView()
                    .tabItem { Label("Add", systemImage: "plus") }
                    .tag(2)
                
                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                    .tag(3)
            }
            .tint(colorScheme == .dark ? .terracottaDarkIcons
                  : .peachColorIcons
            )
            .onAppear {
                setTabBarAppearance(for: colorScheme)
            }
            .onChange(of: colorScheme) { newScheme in
                setTabBarAppearance(for: newScheme)
            }
        }
    }
    
    private func setTabBarAppearance(for scheme: ColorScheme) {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        if scheme == .dark {
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            appearance.backgroundColor = UIColor(.backgroundColorDark2).withAlphaComponent(0.5)
        }
        else {
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
            appearance.backgroundColor = UIColor(.backgroundColorLight).withAlphaComponent(0.8)
        }
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView().modelContainer(PreviewData2.makeModelContainer())
}

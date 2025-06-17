import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab = 0
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var forceUpdate = false
    
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
            .id(forceUpdate)
            .onChange(of: isDarkMode) {
                forceUpdate.toggle()
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .tint(isDarkMode ? .terracottaDarkIcons : .peachColorIcons)
            .onAppear {
                setTabBarAppearance(isDarkMode: isDarkMode)
            }
            .onChange(of: isDarkMode) {
                setTabBarAppearance(isDarkMode: isDarkMode)
            }
        }
    }
    
    private func setTabBarAppearance(isDarkMode: Bool) {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        if isDarkMode {
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            appearance.backgroundColor = UIColor(.backgroundColorDark2).withAlphaComponent(0.7)
        } else {
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
            appearance.backgroundColor = UIColor(.backgroundColorLight).withAlphaComponent(0.7)
        }
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView().modelContainer(PreviewData2.makeModelContainer())
}

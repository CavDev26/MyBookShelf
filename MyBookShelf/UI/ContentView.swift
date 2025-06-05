import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            //Color(colorScheme == .dark ? .black : .white)
            //.ignoresSafeArea()
            TabView {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house.fill") }
                
                MyBooksView2()
                    .tabItem { Label("My Books", systemImage: "books.vertical") }
                
                AddBooksView()
                    .tabItem { Label("Add", systemImage: "plus") }
                
                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                TestView()
                    .tabItem { Label("TEST", systemImage: "seettings") }
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
    ContentView().modelContainer(PreviewData.makeModelContainer())
}

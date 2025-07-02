import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.colorScheme) var systemColorScheme
    @AppStorage("useSystemColorScheme") private var useSystemColorScheme: Bool = true
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @StateObject private var auth = AuthManager()
    @Environment(\.modelContext) private var modelContext


    @State private var selectedTab = 0
    @State private var forceUpdate = false

    private var currentIsDark: Bool {
        useSystemColorScheme ? systemColorScheme == .dark : isDarkMode
    }

    var body: some View {
        TabView(selection: $selectedTab) {
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
        .preferredColorScheme(useSystemColorScheme ? nil : (isDarkMode ? .dark : .light))
        .tint(!currentIsDark ? .terracottaDarkIcons : .peachColorIcons)
        .onAppear {
            setTabBarAppearance(isDark: currentIsDark)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                            Task {
                                await auth.refreshUserInfo()
                                // 2️⃣ Fetch da Firebase
                                await StatsManager.shared.fetchStatsFromFirebase(for: auth.uid, context: modelContext)
                                await StatsManager.shared.fetchChallengesFromFirebase(for: auth.uid, context: modelContext)

                            }
                        }
                }
        .onChange(of: currentIsDark) { _ in
            if useSystemColorScheme {
                setTabBarAppearance(isDark: !currentIsDark)
                forceUpdate.toggle() // forza rebuild
            } else {
                setTabBarAppearance(isDark: currentIsDark)
                forceUpdate.toggle() // forza rebuild
            }
        }
    }

    private func setTabBarAppearance(isDark: Bool) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(isDark ? .backgroundColorDark2 : .backgroundColorLight).withAlphaComponent(0.7)
        appearance.backgroundEffect = UIBlurEffect(style: isDark ? .systemUltraThinMaterialDark : .systemUltraThinMaterialLight)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

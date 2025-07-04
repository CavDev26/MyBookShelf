import SwiftUICore
import SwiftData
import SwiftUI
import SwiftUI
import UserNotifications


struct StartupView: View {
    @EnvironmentObject var auth: AuthManager
    @StateObject var userProfileManager = UserProfileManager()
    @State private var isChecking = true
    @Namespace private var transitionNamespace
    @Environment(\.modelContext) private var modelContext
    @Query var globalStats: [GlobalReadingStats]


    var body: some View {
        ZStack {
            if isChecking {
                ProgressView()
                    .transition(.opacity)
            } else if auth.isLoggedIn {
                ContentView()
                    .environmentObject(auth)
                    .environmentObject(userProfileManager)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                AuthView()
                    .environmentObject(auth)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: auth.isLoggedIn)
        .onAppear {
            WatchSessionManager.shared.setModelContext(modelContext)
            WatchSessionManager.shared.setAuthManager(auth)
            
            requestNotificationPermission()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isChecking = false
                if auth.isLoggedIn {
                    FirebaseBookService.shared.syncBooksToLocal(for: auth.uid, context: modelContext)

                    Task {
                        await auth.refreshUserInfo()
                        // 2️⃣ Fetch da Firebase
                        await StatsManager.shared.fetchStatsFromFirebase(for: auth.uid, context: modelContext)
                        await StatsManager.shared.fetchChallengesFromFirebase(for: auth.uid, context: modelContext)
                        // 3️⃣ Aggiorna stats SOLO se esistono
                        let books = try? modelContext.fetch(FetchDescriptor<SavedBook>())
                        if let books, !books.isEmpty {
                            StatsManager.shared.updateStats(using: books, in: modelContext, uid: auth.uid)
                        }
                    }
                }
            }
        }
    }
    

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notifiche autorizzate")
            } else {
                print("❌ Permesso notifiche negato: \(error?.localizedDescription ?? "unknown")")
            }
        }
    }
    private func ensureStatsExistAndUpdate() {
        if globalStats.isEmpty {
            let stats = GlobalReadingStats()
            modelContext.insert(stats)
            try? modelContext.save()
            print("✅ GlobalReadingStats initialized")
        }

        do {
            let books = try modelContext.fetch(FetchDescriptor<SavedBook>())
            StatsManager.shared.updateStats(using: books, in: modelContext, uid: auth.uid)
        } catch {
            print("❌ Failed to update stats: \(error)")
        }
    }
}

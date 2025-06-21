import SwiftUICore
import SwiftData
//import FirebaseAuth
import SwiftUI
import SwiftUI

struct StartupView: View {
    @EnvironmentObject var auth: AuthManager
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
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                AuthView()
                    .environmentObject(auth)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: auth.isLoggedIn)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isChecking = false
                if auth.isLoggedIn {
                    FirebaseBookService.shared.syncBooksToLocal(for: auth.uid, context: modelContext)

                    Task {
                        await auth.refreshUserInfo()
                        print("sono nell'on Appear di startup")

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

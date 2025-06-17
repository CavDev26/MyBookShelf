import SwiftUICore
//import FirebaseAuth
import SwiftUI
import SwiftUI

struct StartupView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var isChecking = true
    @Namespace private var transitionNamespace
    @Environment(\.modelContext) private var modelContext


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

                }
            }
        }
    }
}

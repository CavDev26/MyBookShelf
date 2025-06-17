import SwiftUICore
import SwiftUI
struct StartupView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var isChecking = true

    var body: some View {
        Group {
            if isChecking {
                ProgressView()
            } else if auth.isLoggedIn {
                ContentView().environmentObject(auth)
            } else {
                AuthView().environmentObject(auth)
            }
        }
        .onAppear {
            isChecking = false
        }
    }
}

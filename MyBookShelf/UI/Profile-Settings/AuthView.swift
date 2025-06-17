import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var isLogin = true
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text(isLogin ? "Login" : "Register")
                .font(.largeTitle).bold()

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let error = errorMessage {
                Text(error).foregroundColor(.red)
            }

            Button(isLogin ? "Login" : "Register") {
                if isLogin {
                    auth.login(email: email, password: password) { error in
                        if let error = error {
                            errorMessage = error
                        } else {
                            dismiss()
                        }
                    }
                } else {
                    auth.register(email: email, password: password) { error in
                        if let error = error {
                            errorMessage = error
                        } else {
                            dismiss()
                        }
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            Button(isLogin ? "Don't have an account? Register" : "Already have an account? Login") {
                isLogin.toggle()
                errorMessage = nil
            }
            .font(.caption)
        }
        .padding()
    }
}

import SwiftUI
import FirebaseAuth
import Firebase
import GoogleSignIn

struct AuthView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var isLoading = false
    @State private var showPassword = false
    @State private var email = ""
    @State private var password = ""
    @State private var isLogin = true
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                .ignoresSafeArea()
            VStack{
                ZStack(alignment: .top) {
                    TopNavBar {
                        Image("MyIcon").resizable().frame(width: 50, height:50)
                        Text("MyBookShelf")
                            .padding(.leading, -10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom("Baskerville-SemiBoldItalic", size: 20))
                    }
                }
                
                VStack(spacing: 20) {
                        
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                            )
                    )

                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)

                        Group {
                            if showPassword {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                        }
                        .autocapitalization(.none)

                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                            )
                    )
                        
                    
                    if let error = errorMessage {
                        Text(error).foregroundColor(.red)
                    }
                    
                    Button(action: {
                        isLoading = true
                        if isLogin {
                            auth.login(email: email, password: password) { error in
                                isLoading = false
                                if let error = error {
                                    errorMessage = error
                                } else {
                                    dismiss()
                                }
                            }
                        } else {
                            auth.register(email: email, password: password) { error in
                                isLoading = false
                                if let error = error {
                                    errorMessage = error
                                } else {
                                    dismiss()
                                }
                            }
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(isLogin ? "Login" : "Register")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: 200)
                        .padding()
                        .background(Color.terracotta)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isLoading)

                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isLogin.toggle()
                            errorMessage = nil
                        }
                    } label: {
                        Text(isLogin ? "Don't have an account? Register" : "Already have an account? Login")
                            .foregroundColor(.terracotta)
                            .font(.caption)
                            .underline()
                    }
                    .padding(.top, 4)
                    
                    Text("or")
                        .foregroundColor(.secondary)
                        .font(.system(size: 15))
                        .padding(20)
                    
                    
                    Button {
                        auth.signInWithGoogle()
                    } label: {
                        HStack(spacing: 10) {
                            Image("Google")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Sign in with Google")
                                .font(.headline)
                        }
                        .frame(maxWidth: 220)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Button {
                        auth.signInWithGoogle()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "apple.logo")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.black)
                            Text("Sign in with Apple")
                                .font(.headline)
                        }
                        .frame(maxWidth: 220)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    
                }
                .padding()
            }
        }
        .preferredColorScheme(.light)
    }
    
    
    /*func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first?.rootViewController else {
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                print("Google Sign-In error: \(error)")
                return
            }

            guard let idToken = result?.user.idToken?.tokenString,
                  let accessToken = result?.user.accessToken.tokenString else {
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Sign-In error: \(error)")
                } else if let user = authResult?.user {
                    // 🔐 Aggiorna lo stato in AuthManager
                    DispatchQueue.main.async {
                        auth.isLoggedIn = true
                        auth.email = user.email ?? ""
                        auth.uid = user.uid
                    }
                    auth.syncUserDocumentWith(uid: user.uid, email: user.email ?? "")
                }
            }
        }
    }*/
}

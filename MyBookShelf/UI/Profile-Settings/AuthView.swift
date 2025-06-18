import SwiftUI
import FirebaseAuth

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
                }
                .padding()
            }
        }
        .preferredColorScheme(.light)
    }
}

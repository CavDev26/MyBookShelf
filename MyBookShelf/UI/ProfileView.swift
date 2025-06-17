//
//  ProfileView.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 25/05/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("username") private var username: String = ""
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .top) {
                Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                    .ignoresSafeArea()
                VStack{
                    ZStack(alignment: .top) {
                        TopNavBar {
                            Image("MyIcon").resizable().frame(width: 50, height:50)
                            Text("Settings")
                                .padding(.leading, -10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.custom("Baskerville-SemiBoldItalic", size: 20))
                        }
                    }
                    List {
                        Section {
                            if isLoggedIn {
                                    HStack {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .frame(width: 48, height: 48)
                                            .foregroundColor(.gray)
                                        
                                        VStack(alignment: .leading) {
                                            Text(username)
                                                .font(.headline)
                                            Text("Apple ID, iCloud, and more")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                } else {
                                    NavigationLink(destination: AuthView()) {
                                        HStack {
                                            Image(systemName: "person.crop.circle.badge.plus")
                                                .resizable()
                                                .frame(width: 48, height: 48)
                                                .foregroundColor(.gray)
                                            
                                            VStack(alignment: .leading) {
                                                Text("Accedi o registrati")
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                Text("Crea un account o accedi")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                }                        }
                        .listRowBackground(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                        
                        
                        Section(header: Text("General")) {
                            NavigationLink(destination: Text("Preferences View")) {
                                Label("Preferences", systemImage: "gearshape")
                            }
                            
                            NavigationLink(destination: NotificationView()) {
                                Label("Notifications", systemImage: "bell")
                            }
                        }.listRowBackground(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                        
                        Section(header: Text("Others")) {
                            
                            Toggle(isOn: $isDarkMode) {
                                Label("Dark Mode", systemImage: "moon.fill")
                            }
                            
                            NavigationLink(destination: Text("Privacy View")) {
                                Label("Privacy", systemImage: "hand.raised.fill")
                            }
                            
                            NavigationLink(destination: Text("About View")) {
                                Label("About", systemImage: "info.circle")
                            }
                        }.listRowBackground(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.insetGrouped)
                }
                
            }
        }
    }
}


struct AuthView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("username") private var savedUsername = ""
    @AppStorage("password") private var savedPassword = ""

    @State private var username = ""
    @State private var password = ""
    @State private var isRegistering = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text(isRegistering ? "Registrati" : "Accedi")
                .font(.title)
                .bold()

            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            Button(isRegistering ? "Registrati" : "Accedi") {
                handleAuth()
            }
            .buttonStyle(.borderedProminent)

            Button(isRegistering ? "Hai già un account? Accedi" : "Non hai un account? Registrati") {
                isRegistering.toggle()
            }
            .font(.footnote)
            .padding(.top)

            Spacer()
        }
        .padding()
    }

    func handleAuth() {
        if isRegistering {
            // Registrazione
            savedUsername = username
            savedPassword = password
            isLoggedIn = true
            dismiss()
        } else {
            // Login
            if username == savedUsername && password == savedPassword {
                isLoggedIn = true
                dismiss()
            } else {
                // Puoi mostrare un alert qui
                print("❌ Username o password errati")
            }
        }
    }
}

struct NotificationView: View {
    var body: some View {
        Text("Notifiche - impostazioni")
    }
}

#Preview {
    ProfileView()
}

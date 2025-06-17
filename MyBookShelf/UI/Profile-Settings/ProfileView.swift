//
//  ProfileView.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 25/05/25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var auth: AuthManager

    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    //@AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
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
                            if auth.isLoggedIn {
                                    HStack {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .frame(width: 48, height: 48)
                                            .foregroundColor(.gray)
                                        
                                        VStack(alignment: .leading) {
                                            Text(auth.email)
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
                            
                            Button(role: .destructive) {
                                auth.logout()
                            } label: {
                                Label("Logout", systemImage: "rectangle.portrait.and.arrow.forward")
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

struct NotificationView: View {
    var body: some View {
        Text("Notifiche - impostazioni")
    }
}

#Preview {
    ProfileView()
}

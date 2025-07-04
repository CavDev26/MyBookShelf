//
//  ProfileView.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 25/05/25.
//
import LocalAuthentication
import SwiftUI
import FirebaseAuth
import SwiftData

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var auth: AuthManager
    @EnvironmentObject var userProfile: UserProfileManager
    @State private var showLogoutConfirmation = false
    @State private var isDiaryUnlocked = false
    @State private var showDiaryAuthError = false
    @Environment(\.modelContext) private var context
    @State private var nickname: String = ""
    
    
    @StateObject private var exportVM = ExportLibraryViewModel()
    @State private var showExportPicker = false
    @State private var selectedExportFormat: ExportFormat? = nil
    @Query private var savedBooks: [SavedBook]
    struct IdentifiableURL: Identifiable {
        var id: URL { url }
        let url: URL
    }
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("username") private var username: String = ""
    @AppStorage("useSystemColorScheme") private var useSystemColorScheme: Bool = true
    
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
                        Section (header: Text("Account")) {
                            if auth.isLoggedIn {
                                NavigationLink(destination: AccountView()) {
                                    VStack {
                                        Group {
                                            if let image = userProfile.profileImage {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .clipShape(Circle())
                                            } else {
                                                Image(systemName: "person.crop.circle.fill")
                                                    .resizable()
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .frame(width: 100, height: 100)
                                        .padding()
                                        
                                        VStack(alignment: .leading) {
                                            Text(userProfile.nickname.isEmpty ? auth.email : userProfile.nickname)
                                                .font(.headline)
                                                .padding(.bottom)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
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
                            }
                        }
                        .listRowBackground(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                        
                        
                        Section(header: Text("General")) {
                            NavigationLink(destination: PreferencesView()) {
                                Label("Preferences", systemImage: "gearshape")
                            }
                            
                            NavigationLink(destination: NotificationView()) {
                                Label("Notifications", systemImage: "bell")
                            }
                        }
                        .listRowBackground(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                        
                        
                        Section(header: Text("Appearance")) {
                            Toggle(isOn: $useSystemColorScheme) {
                                Label("Automatic Theme", systemImage: "circle.lefthalf.fill")
                            }
                            Toggle(isOn: $isDarkMode) {
                                Label("Dark Mode", systemImage: "moon.fill")
                            }
                            .disabled(useSystemColorScheme)
                        }
                        .listRowBackground(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                        
                        Section(header: Text("Others")) {
                            
                            NavigationLink(destination: AboutView()) {
                                Label("About", systemImage: "info.circle")
                            }
                            
                            Button {
                                showExportPicker = true
                            } label: {
                                Label("Export Library", systemImage: "square.and.arrow.up")
                            }
                            Button(role: .destructive) {
                                showLogoutConfirmation = true
                            } label: {
                                Label("Logout", systemImage: "rectangle.portrait.and.arrow.forward")
                                    .padding(.leading, 4)
                            }
                            .alert("Are you sure you want to logout?", isPresented: $showLogoutConfirmation) {
                                Button("Cancel", role: .cancel) { }
                                Button("Logout", role: .destructive) {
                                    auth.logout(context: context, userProfile: userProfile)
                                }
                            } message: {
                                Text("This action will disconnect your account.")
                            }
                            
                        }.listRowBackground(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                        
                        Section {
                            if auth.isLoggedIn {
                                Button {
                                    authenticateForDiary()
                                } label: {
                                    HStack{
                                        HStack{
                                            Image(systemName: "book.pages")
                                                .padding(.trailing)
                                            Text("My Diary")
                                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        Image(systemName: "lock")
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                }
                            }
                        }.listRowBackground(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                    }
                    .navigationDestination(isPresented: $isDiaryUnlocked) {
                        ReadingDiaryView()
                    }
                    .alert("Authentication Failed", isPresented: $showDiaryAuthError) {
                        Button("OK", role: .cancel) { }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.insetGrouped)
                }
                .onAppear {
                    if auth.isLoggedIn {
                        userProfile.loadProfile(for: auth.uid)
                    }
                }
                .actionSheet(isPresented: $showExportPicker) {
                    ActionSheet(title: Text("Select export format"), buttons: ExportFormat.allCases.map { format in
                        .default(Text(format.rawValue.uppercased())) {
                            selectedExportFormat = format
                            exportVM.exportLibrary(as: format, books: savedBooks)
                        }
                    } + [.cancel()])
                }
                .sheet(item: $exportVM.exportFile) { identifiable in
                    ShareSheet(activityItems: [identifiable.url])
                }
            }
        }
    }
    /*func loadProfileImage() {
        let userRef = Firestore.firestore().collection("users").document(auth.uid)
        userRef.getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let base64String = data["profileImageBase64"] as? String,
               let imageData = Data(base64Encoded: base64String),
               let uiImage = UIImage(data: imageData),
               let nick = data["nickname"] as? String {
                profileImage = uiImage
                nickname = nick
            }
        }
    }*/
    func authenticateForDiary() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock your private diary"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    if success {
                        isDiaryUnlocked = true
                    } else {
                        showDiaryAuthError = true
                    }
                }
            }
        } else {
            showDiaryAuthError = true
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

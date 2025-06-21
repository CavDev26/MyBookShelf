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
    @State private var showLogoutConfirmation = false
    @State private var isDiaryUnlocked = false
    @State private var showDiaryAuthError = false
    @Environment(\.modelContext) private var context

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
                        Section {
                            if auth.isLoggedIn {
                                NavigationLink(destination: AccountView()) {
                                    HStack {
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .frame(width: 48, height: 48)
                                            .foregroundColor(.gray)
                                        
                                        VStack(alignment: .leading) {
                                            Text(auth.email)
                                                .font(.headline)
                                        }
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
                            
                            NavigationLink(destination: Text("Privacy View")) {
                                Label("Privacy", systemImage: "hand.raised.fill")
                            }
                            
                            NavigationLink(destination: Text("About View")) {
                                Label("About", systemImage: "info.circle")
                            }
                            
                            Button(role: .destructive) {
                                showLogoutConfirmation = true
                            } label: {
                                Label("Logout", systemImage: "rectangle.portrait.and.arrow.forward")
                            }
                            .alert("Are you sure you want to logout?", isPresented: $showLogoutConfirmation) {
                                Button("Cancel", role: .cancel) { }
                                Button("Logout", role: .destructive) {
                                    auth.logout(context: context)
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
                
            }
        }
    }
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
            // Fall back or show alert if no biometrics are available
            showDiaryAuthError = true
        }
    }
}

struct NotificationView: View {
    var body: some View {
        Text("Notifiche - impostazioni")
    }
}



struct AccountView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var auth: AuthManager

    @State private var showImagePicker = false
    @State private var showChangeEmailSheet = false
    @State private var newPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        Button {
                            showImagePicker = true
                        } label: {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "camera")
                                        .font(.title)
                                        .foregroundColor(.primary)
                                )
                        }
                        Spacer()
                    }
                }

                Section(header: Text("Email")) {
                    HStack {
                        Text("Current:")
                        Spacer()
                        Text(auth.email)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }

                    Button("Change Email") {
                        showChangeEmailSheet = true
                    }
                }

                Section(header: Text("New Password")) {
                    SecureField("••••••••", text: $newPassword)

                    Button("Change Password") {
                        auth.updatePassword(to: newPassword) { error in
                            if let error = error {
                                alertMessage = "⚠️ \(error)"
                            } else {
                                alertMessage = "✅ Password aggiornata con successo"
                            }
                            showAlert = true
                        }
                    }
                    .disabled(newPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .customNavigationTitle("Account Settings")
            .sheet(isPresented: $showChangeEmailSheet) {
                ChangeEmailSheetView()
                    .environmentObject(auth)
            }
            .alert("Account Update", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

struct ChangeEmailSheetView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context

    @State private var newEmail: String = ""
    @State private var password: String = ""
    @State private var feedbackMessage: String?
    @State private var isSuccess: Bool = false
    @State private var isLoading: Bool = false
    @State private var isWaitingForVerification = false
    @State private var timer: Timer?

    var body: some View {
        NavigationStack {
            Form {
                if isWaitingForVerification {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Check your inbox and verify your new email.", systemImage: "envelope.badge")
                                .foregroundColor(.blue)
                            Button("I have verified") {
                                checkVerificationStatus(context: context)
                            }
                        }
                    }
                } else {
                    Section(header: Text("Current Email")) {
                        Text(auth.email)
                            .foregroundColor(.secondary)
                    }

                    Section(header: Text("New Email")) {
                        TextField("new.email@example.com", text: $newEmail)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }

                    Section(header: Text("Password")) {
                        SecureField("Enter current password", text: $password)
                    }

                    if let message = feedbackMessage {
                        Section {
                            Label {
                                Text(message)
                            } icon: {
                                Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .foregroundColor(isSuccess ? .green : .red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Change Email")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        timer?.invalidate()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isLoading {
                        ProgressView()
                    } else if !isWaitingForVerification {
                        Button("Save") {
                            Task {
                                await changeEmail()
                            }
                        }
                        .disabled(newEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || password.isEmpty)
                    }
                }
            }
        }
    }

    func changeEmail() async {
        isLoading = true
        feedbackMessage = nil
        isSuccess = false

        let result = await auth.updateEmail(to: newEmail, currentPassword: password)
        await MainActor.run {
            switch result {
            case .success:
                feedbackMessage = "Email updated. Please verify your new email before continuing."
                isSuccess = true
                isWaitingForVerification = true
                startVerificationPolling()
            case .failure(let error):
                feedbackMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func checkVerificationStatus(context: ModelContext) {
        Task {
            do {
                try await Auth.auth().currentUser?.reload()
                if Auth.auth().currentUser?.isEmailVerified == true {
                    await MainActor.run {
                        timer?.invalidate()

                        // 👉 logout completo
                            auth.logout(context: context)
                        /*if let context = try? Environment(\.modelContext).wrappedValue {
                            auth.logout(context: context)
                        }*/

                        dismiss()
                    }
                } else {
                    feedbackMessage = "❗️ Email not yet verified."
                }
            } catch {
                feedbackMessage = error.localizedDescription
            }
        }
    }

    func startVerificationPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            checkVerificationStatus(context: context)
        }
    }
}

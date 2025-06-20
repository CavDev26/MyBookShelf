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
import FirebaseFirestore


struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var auth: AuthManager
    @State private var showLogoutConfirmation = false
    @State private var isDiaryUnlocked = false
    @State private var showDiaryAuthError = false
    @Environment(\.modelContext) private var context
    @State private var profileImage: UIImage? = nil

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
                                        Group {
                                            if let image = profileImage {
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
                .onAppear {
                    if auth.isLoggedIn {
                        loadProfileImage()
                    }
                }
                
            }
        }
    }
    func loadProfileImage() {
        let userRef = Firestore.firestore().collection("users").document(auth.uid)
        userRef.getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let base64String = data["profileImageBase64"] as? String,
               let imageData = Data(base64Encoded: base64String),
               let uiImage = UIImage(data: imageData) {
                profileImage = uiImage
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



// AccountView.swift

struct AccountView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var auth: AuthManager

    @State private var selectedImage: UIImage? = nil
    @State private var showingSourceDialog = false
    @State private var showingCamera = false
    @State private var showingImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showImagePicker = false
    @State private var showChangeEmailSheet = false
    @State private var newPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isUploading = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                    .ignoresSafeArea()
                List {
                    Section {
                        HStack {
                            Spacer()
                            Button {
                                showingSourceDialog = true
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 150, height: 150)

                                    if let image = selectedImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 150)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "camera")
                                            .font(.title)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            .confirmationDialog("Choose Image Source", isPresented: $showingSourceDialog) {
                                Button("Photo Library") {
                                    imagePickerSource = .photoLibrary
                                    showingImagePicker = true
                                }
                                Button("Camera") {
                                    imagePickerSource = .camera
                                    showingImagePicker = true
                                }
                                Button("Cancel", role: .cancel) { }
                            }
                            .sheet(isPresented: $showingImagePicker) {
                                ImagePicker(sourceType: imagePickerSource, selectedImage: $selectedImage)
                                    .onDisappear {
                                        if let image = selectedImage {
                                            uploadProfileImage(image, for: auth.uid)
                                        }
                                    }
                            }
                            Spacer()
                        }
                    }.listRowBackground(Color.clear)

                    Section(header: Text("Email")) {
                        Text(auth.email)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)

                        Button {
                            showChangeEmailSheet = true
                        } label : {
                            Text("Change Email")
                                .frame(maxWidth: .infinity)
                        }
                    }.listRowBackground(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)

                    Section(header: Text("New Password")) {
                        SecureField("Insert new password", text: $newPassword)

                        Button{
                            auth.updatePassword(to: newPassword) { error in
                                if let error = error {
                                    alertMessage = "\(error)"
                                } else {
                                    alertMessage = "Password aggiornata con successo"
                                }
                                showAlert = true
                            }
                        } label: {
                            Text("Change Password")
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(newPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }.listRowBackground(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                }
                .scrollContentBackground(.hidden)
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
            .onAppear {
                loadProfileImage()
            }
        }
    }

    func uploadProfileImage(_ image: UIImage, for uid: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }

        let base64String = imageData.base64EncodedString()

        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.setData(["profileImageBase64": base64String], merge: true) { error in
            if let error = error {
                alertMessage = "❌ Firestore upload error: \(error.localizedDescription)"
                showAlert = true
            } else {
                alertMessage = "✅ Immagine caricata con successo!"
                showAlert = true
            }
        }
    }
    func loadProfileImage() {
        let userRef = Firestore.firestore().collection("users").document(auth.uid)
        userRef.getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let base64String = data["profileImageBase64"] as? String,
               let imageData = Data(base64Encoded: base64String),
               let uiImage = UIImage(data: imageData) {
                selectedImage = uiImage
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

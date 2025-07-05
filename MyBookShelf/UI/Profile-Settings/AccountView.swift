//
//  AccountView.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 04/07/25.
//
import SwiftUI
import SwiftUICore
import FirebaseFirestore
import SwiftData
import FirebaseAuth
import AVFoundation

struct AccountView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var auth: AuthManager
    @EnvironmentObject var userProfile: UserProfileManager
    
    @EnvironmentObject var permissionManager: PermissionManager
    @State private var showCameraPermissionAlert = false

    @State private var selectedImage: UIImage? = nil
    @State private var showingSourceDialog = false
    @State private var showingCamera = false
    @State private var showingImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showImagePicker = false
    @State private var showChangeEmailSheet = false
    @State private var newPassword = ""
    @State private var showAlert = false
    @State var alertMessage = ""
    @State private var isUploading = false
    @State private var nickname: String = ""
    @State private var originalImage: UIImage? = nil
    
    @State var showCustomAlert: Bool = false
    @State var successAlert: Bool = false
    
    
    
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
                                    switch AVCaptureDevice.authorizationStatus(for: .video) {
                                    case .authorized:
                                        imagePickerSource = .camera
                                        showingImagePicker = true
                                    case .notDetermined:
                                        AVCaptureDevice.requestAccess(for: .video) { granted in
                                            DispatchQueue.main.async {
                                                if granted {
                                                    imagePickerSource = .camera
                                                    showingImagePicker = true
                                                } else {
                                                    showCameraPermissionAlert = true
                                                }
                                                permissionManager.checkCameraPermission()
                                            }
                                        }
                                    case .denied, .restricted:
                                        showCameraPermissionAlert = true
                                    default:
                                        showCameraPermissionAlert = true
                                    }
                                }
                                Button("Cancel", role: .cancel) { }
                            }
                            .fullScreenCover(isPresented: $showingImagePicker) {
                                ImagePicker(sourceType: imagePickerSource, selectedImage: $selectedImage)
                                    .onDisappear {
                                        if let image = selectedImage, image != originalImage {
                                            uploadProfileImage(image, for: auth.uid)
                                        }
                                    }
                                    .preferredColorScheme(imagePickerSource == .photoLibrary ? colorScheme : .dark)
                                    //.preferredColorScheme(.dark)
                                    .ignoresSafeArea()
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
                            UIApplication.shared.endEditing()
                            auth.updatePassword(to: newPassword) { error in
                                if let error = error as NSError? {
                                    if error.localizedDescription == "" {
                                        alertMessage = "Error updating password"
                                    } else {
                                        alertMessage = "\(error.localizedDescription)"
                                    }
                                    successAlert = false
                                } else {
                                    alertMessage = "Password succesfully updated!"
                                    successAlert = true
                                }
                                showCustomAlert = true
                                //showAlert = true
                            }
                        } label: {
                            Text("Change Password")
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(newPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }.listRowBackground(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                    
                    Section(header: Text("Nickname")) {
                        TextField("Enter your nickname", text: $nickname)
                        Button {
                            UIApplication.shared.endEditing()
                            saveNickname()
                        } label: {
                            Text("Save Nickname")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .listRowBackground(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                }
                .scrollContentBackground(.hidden)
                
                Spacer()
                
                if isUploading {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView("Uploading...")
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                        .shadow(radius: 10)
                }
                if showCustomAlert {
                    CustomAlertView(message: alertMessage, success: successAlert) {
                        showCustomAlert = false
                    }
                }
            }
            .customNavigationTitle("Account Settings")
            .fullScreenCover(isPresented: $showChangeEmailSheet) {
                ChangeEmailSheetView()
                    .environmentObject(auth)
            }
            /*.alert("Account Update", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }*/
            .alert("Camera Access Required", isPresented: $showCameraPermissionAlert) {
                Button("Open Settings") {
                    permissionManager.openAppSettings()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("To take a profile picture, please enable camera access in Settings.")
            }
            
            .onAppear {
                loadProfileImage()
            }
        }
    }

    func saveNickname() {
        //showAlert = true
        let db = Firestore.firestore()
        let usersRef = db.collection("users")
        
        // 1. Cerca se esiste già un altro utente con questo nickname
        usersRef.whereField("nickname", isEqualTo: nickname).getDocuments { snapshot, error in
            if let error = error {
                successAlert = false
                alertMessage = "Error checking nickname: \(error.localizedDescription)"
                //showAlert = true
                showCustomAlert = true
                return
            }

            let documents = snapshot?.documents ?? []

            // 2. Se esiste un altro utente con quel nickname, blocca
            if documents.contains(where: { $0.documentID != auth.uid }) {
                successAlert = false
                alertMessage = "Nickname already taken. Please choose another one."
                //showAlert = true
                showCustomAlert = true
                return
            }

            // 3. Altrimenti, salva il nickname
            let userRef = usersRef.document(auth.uid)
            userRef.setData(["nickname": nickname], merge: true) { error in
                if let error = error {
                    successAlert = false
                    alertMessage = "Error saving Nickname: \(error.localizedDescription)"
                } else {
                    successAlert = true
                    alertMessage = "Nickname succesfully updated!"
                }
                //showAlert = true
                showCustomAlert = true
            }

            userProfile.loadProfile(for: auth.uid)
        }
    }
    
    func uploadProfileImage(_ image: UIImage, for uid: String) {
        let resizedImage = resizeImage(image: image, maxDimension: 300)
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.3) else { return }
        let base64String = imageData.base64EncodedString()
        isUploading = true

        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.setData(["profileImageBase64": base64String], merge: true) { error in
            isUploading = false
            if let error = error {
                successAlert = false
                alertMessage = "Image upload error: \(error.localizedDescription)"
            } else {
                successAlert = true
                alertMessage = "Image successfully uploaded!"
            }
            showCustomAlert = true
            //showAlert = true
        }
    }
    
    func loadProfileImage() {
        let userRef = Firestore.firestore().collection("users").document(auth.uid)
        userRef.getDocument { snapshot, error in
            guard let snapshot = snapshot, let data = snapshot.data() else { return }

            if let base64String = data["profileImageBase64"] as? String,
               let imageData = Data(base64Encoded: base64String),
               let uiImage = UIImage(data: imageData) {
                selectedImage = uiImage
                originalImage = uiImage // salva anche l'immagine originale
            }

            if let savedNickname = data["nickname"] as? String {
                nickname = savedNickname
            }
        }
    }
    
    func resizeImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        let aspectRatio = image.size.width / image.size.height
        var newSize: CGSize

        if aspectRatio > 1 {
            // landscape
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            // portrait or square
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
}


struct ChangeEmailSheetView: View {
    @EnvironmentObject var auth: AuthManager
    @EnvironmentObject var userProfile: UserProfileManager
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
                        auth.logout(context: context, userProfile: userProfile)
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


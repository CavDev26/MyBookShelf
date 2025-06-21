//  AuthManager.swift
import Foundation
import FirebaseAuth
import SwiftUI
import SwiftData

class AuthManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var email: String = ""
    @Published var uid: String = ""

    init() {
        let user = Auth.auth().currentUser
        self.isLoggedIn = user != nil
        self.email = user?.email ?? ""
        self.uid = user?.uid ?? ""
    }

    func login(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error.localizedDescription)
            } else if let user = result?.user {
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                    self.email = user.email ?? ""
                    self.uid = user.uid
                }
                completion(nil)
            }
        }
    }

    func register(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error.localizedDescription)
            } else if let user = result?.user {
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                    self.email = user.email ?? ""
                    self.uid = user.uid
                }
                completion(nil)
            }
        }
    }

    func logout(context: ModelContext) {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isLoggedIn = false
                self.email = ""
                self.uid = ""

                // 🔁 CANCELLA DATI LOCALI
                do {
                    let allBooks = try context.fetch(FetchDescriptor<SavedBook>())
                    allBooks.forEach { context.delete($0) }

                    let allStats = try context.fetch(FetchDescriptor<GlobalReadingStats>())
                    allStats.forEach { context.delete($0) }

                    let allYearly = try context.fetch(FetchDescriptor<YearlyReadingChallenge>())
                    allYearly.forEach { context.delete($0) }

                    let allMonthly = try context.fetch(FetchDescriptor<MonthlyReadingChallenge>())
                    allMonthly.forEach { context.delete($0) }

                    try context.save()
                    print("🧹 Dati locali cancellati con successo")
                } catch {
                    print("❌ Errore nella pulizia dei dati locali: \(error)")
                }
            }
        } catch {
            print("Logout error: \(error.localizedDescription)")
        }
    }
    
    func updateEmail(to newEmail: String, currentPassword: String) async -> Result<Void, Error> {
        guard let user = Auth.auth().currentUser,
              let currentEmail = user.email else {
            return .failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Utente non autenticato"]))
        }

        let credential = EmailAuthProvider.credential(withEmail: currentEmail, password: currentPassword)

        do {
            try await user.reauthenticate(with: credential)
            try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
            await MainActor.run {
                self.email = newEmail
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func updatePassword(to newPassword: String, completion: @escaping (String?) -> Void) {
        Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
            completion(error?.localizedDescription)
        }
    }
    func refreshUserInfo() async {
        guard let user = Auth.auth().currentUser else { return }
        do {
            try await user.reload()
            await MainActor.run {
                self.email = user.email ?? ""
                self.uid = user.uid
                self.isLoggedIn = true
            }
        } catch {
            print("❌ Failed to reload user info: \(error.localizedDescription)")
        }
    }
}

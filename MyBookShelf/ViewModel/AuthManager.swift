//  AuthManager.swift
import Foundation
import FirebaseAuth
import SwiftUI
import SwiftData
import FirebaseFirestore

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
                    
                    //self.syncUserDocument()
                }
                self.syncUserDocumentWith(uid: user.uid, email: user.email ?? "")
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
                    
                    //self.syncUserDocument()
                }
                self.syncUserDocumentWith(uid: user.uid, email: user.email ?? "")
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
                    
                    let allShelves = try context.fetch(FetchDescriptor<Shelf>())
                    allShelves.forEach { context.delete($0) }

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
    
    
    
    
    
    
    
    
    
    func syncUserDocument(nickname: String? = nil, profileImageBase64: String? = nil) {
        let db = Firestore.firestore()
        let statsRef = db.collection("users").document(uid).collection("stats").document("global")
        let userRef = db.collection("users").document(uid)

        statsRef.getDocument { statsSnapshot, _ in
            let xp = statsSnapshot?.data()?["experiencePoints"] as? Int ?? 0
            let level = xp / 100

            userRef.getDocument { snapshot, error in
                var dataToUpdate: [String: Any] = [:]

                if let snapshot = snapshot, snapshot.exists {
                    // Documento esistente: aggiorna solo i campi mancanti
                    let data = snapshot.data() ?? [:]
                    if data["email"] == nil { dataToUpdate["email"] = self.email }
                    if data["level"] == nil { dataToUpdate["level"] = level }
                    if data["nickname"] == nil {
                        dataToUpdate["nickname"] = nickname ?? "User\(Int.random(in: 1000...9999))"
                    }
                    if data["profileImageBase64"] == nil, let imageBase64 = profileImageBase64 {
                        dataToUpdate["profileImageBase64"] = imageBase64
                    }
                } else {
                    // Documento assente: crea tutto
                    dataToUpdate = [
                        "email": self.email,
                        "level": level,
                        "nickname": nickname ?? "User\(Int.random(in: 1000...9999))"
                    ]
                    if let imageBase64 = profileImageBase64 {
                        dataToUpdate["profileImageBase64"] = imageBase64
                    }
                }

                if !dataToUpdate.isEmpty {
                    userRef.setData(dataToUpdate, merge: true) { error in
                        if let error = error {
                            print("❌ Errore aggiornamento utente: \(error.localizedDescription)")
                        } else {
                            print("✅ Utente sincronizzato correttamente (livello: \(level))")
                        }
                    }
                }
            }
        }
    }
    
    /*func syncUserDocumentWith(uid: String, email: String, nickname: String? = nil, profileImageBase64: String? = nil) {
        print("🚀 Chiamata syncUserDocumentWith con uid: \(uid), email: \(email)")

        let db = Firestore.firestore()
        let statsRef = db.collection("users").document(uid).collection("stats").document("global")
        let userRef = db.collection("users").document(uid)

        statsRef.getDocument { statsSnapshot, error in
            if let error = error {
                print("❌ Errore fetching stats: \(error.localizedDescription)")
            }

            let xp = statsSnapshot?.data()?["experiencePoints"] as? Int ?? 0
            let level = xp / 100
            print("📊 XP: \(xp) -> livello calcolato: \(level)")

            // 🔁 FORZA l'aggiornamento di tutti i campi
            var dataToUpdate: [String: Any] = [
                "email": email,
                "level": level,
                "nickname": nickname ?? "User\(Int.random(in: 1000...9999))",
                "profileImageBase64": profileImageBase64 ?? ""
            ]

            print("📝 Scrittura su Firestore (forzata): \(dataToUpdate)")

            userRef.setData(dataToUpdate, merge: true) { error in
                if let error = error {
                    print("❌ Errore aggiornamento utente: \(error.localizedDescription)")
                } else {
                    print("✅ Utente sincronizzato correttamente (livello: \(level))")
                }
            }
        }
    }*/
    
    
    
    func syncUserDocumentWith(uid: String, email: String, nickname: String? = nil, profileImageBase64: String? = nil) {
        print("🚀 Chiamata syncUserDocumentWith con uid: \(uid), email: \(email)")
        
        let db = Firestore.firestore()
        let statsRef = db.collection("users").document(uid).collection("stats").document("global")
        let userRef = db.collection("users").document(uid)

        statsRef.getDocument { statsSnapshot, error in
            if let error = error {
                print("❌ Errore fetching stats: \(error.localizedDescription)")
            }
            let xp = statsSnapshot?.data()?["experiencePoints"] as? Int ?? 0
            let level = xp / 100
            print("📊 XP: \(xp) -> livello calcolato: \(level)")

            userRef.getDocument { snapshot, error in
                var dataToUpdate: [String: Any] = [:]

                if let snapshot = snapshot, snapshot.exists {
                    let data = snapshot.data() ?? [:]
                    if data["email"] == nil { dataToUpdate["email"] = email }
                    if data["level"] == nil { dataToUpdate["level"] = level }
                    if data["nickname"] == nil {
                        dataToUpdate["nickname"] = nickname ?? "User\(Int.random(in: 1000...9999))"
                    }
                    if data["profileImageBase64"] == nil, let imageBase64 = profileImageBase64 {
                        dataToUpdate["profileImageBase64"] = imageBase64
                    }
                } else {
                    dataToUpdate = [
                        "email": email,
                        "level": level,
                        "nickname": nickname ?? "User\(Int.random(in: 1000...9999))"
                    ]
                    if let imageBase64 = profileImageBase64 {
                        dataToUpdate["profileImageBase64"] = imageBase64
                    }
                }

                print("📝 Scrittura su Firestore: \(dataToUpdate)")

                if !dataToUpdate.isEmpty {
                    print("📝 Scrittura su Firestore: \(dataToUpdate)")
                    userRef.setData(dataToUpdate, merge: true) { error in
                        if let error = error {
                            print("❌ Errore aggiornamento utente: \(error.localizedDescription)")
                        } else {
                            print("✅ Utente sincronizzato correttamente (livello: \(level))")
                        }
                    }
                }
            }
        }
    }
    
}

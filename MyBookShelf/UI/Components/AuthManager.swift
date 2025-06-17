//  AuthManager.swift
import Foundation
import FirebaseAuth
import SwiftUI

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

    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isLoggedIn = false
                self.email = ""
                self.uid = ""
            }
        } catch {
            print("Logout error: \(error.localizedDescription)")
        }
    }
}

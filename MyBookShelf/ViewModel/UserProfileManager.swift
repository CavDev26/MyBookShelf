//
//  UserProfileManager.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 04/07/25.
//

import Foundation
import UIKit
import FirebaseFirestore


class UserProfileManager: ObservableObject {
    @Published var nickname: String = ""
    @Published var profileImage: UIImage? = nil

    func loadProfile(for uid: String) {
        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.getDocument { snapshot, error in
            guard let data = snapshot?.data() else { return }

            DispatchQueue.main.async {
                if let nick = data["nickname"] as? String {
                    self.nickname = nick
                }

                if let base64 = data["profileImageBase64"] as? String,
                   let data = Data(base64Encoded: base64),
                   let image = UIImage(data: data) {
                    self.profileImage = image
                }
            }
        }
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.nickname = ""
            self.profileImage = nil
        }
    }
}

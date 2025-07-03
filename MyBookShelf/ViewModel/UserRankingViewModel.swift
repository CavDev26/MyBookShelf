//
//  UserRankingViewModel.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 03/07/25.
//

import Foundation
import FirebaseFirestore


class UserRankingViewModel: ObservableObject {
    @Published var users: [UserRanking] = []

    func loadUsers() {
        FirebaseUserService.shared.fetchUsers { users in
            DispatchQueue.main.async {
                self.users = users
            }
        }
    }
}

class FirebaseUserService {
    static let shared = FirebaseUserService()
    
    func fetchUsers(completion: @escaping ([UserRanking]) -> Void) {
        Firestore.firestore().collection("users").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                completion([])
                return
            }

            let users = documents.compactMap { doc -> UserRanking? in
                let data = doc.data()
                guard let email = data["email"] as? String,
                      let level = data["level"] as? Int else { return nil }
                return UserRanking(id: doc.documentID, email: email, level: level)
            }

            // Ordinamento per livello
            let sorted = users.sorted { $0.level > $1.level }
            completion(sorted)
        }
    }
}

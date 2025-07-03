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
    @Published var currentUser: UserRanking?
    @Published var currentRank: Int?

    func loadUsers(currentUserID: String) {
        FirebaseUserService.shared.fetchUsers { users in
            DispatchQueue.main.async {
                self.users = users
                if let index = users.firstIndex(where: { $0.id == currentUserID }) {
                    self.currentUser = users[index]
                    self.currentRank = index + 1
                }
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
                      let level = data["level"] as? Int,
                      let nickname = data["nickname"] as? String,
                      let proPic = data["profileImageBase64"] as? String? else { return nil }
                return UserRanking(id: doc.documentID, email: email, level: level, nickname: nickname, proPic: proPic)
            }

            // Ordinamento per livello
            let sorted = users.sorted { $0.level > $1.level }
            completion(sorted)
        }
    }
}

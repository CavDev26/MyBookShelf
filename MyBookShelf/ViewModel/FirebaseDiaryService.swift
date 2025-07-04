import FirebaseFirestore

class FirebaseDiaryService {
    static let shared = FirebaseDiaryService()
    private let db = Firestore.firestore()

    func saveEntry(for dateKey: String, text: String, uid: String, completion: @escaping () -> Void) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedText.isEmpty {
            // Non salvare nulla se è vuoto (eventualmente potresti anche cancellare se esiste)
            db.collection("users").document(uid)
                .collection("diary")
                .document(dateKey)
                .delete(completion: { _ in
                    completion()
                })
        } else {
            db.collection("users").document(uid)
                .collection("diary")
                .document(dateKey)
                .setData([
                    "text": trimmedText,
                    "timestamp": Date()
                ]) { _ in
                    completion()
                }
        }
    }

    func loadEntry(for dateKey: String, uid: String, completion: @escaping (String?) -> Void) {
        db.collection("users").document(uid)
            .collection("diary")
            .document(dateKey)
            .getDocument { snapshot, _ in
                if let data = snapshot?.data(), let text = data["text"] as? String {
                    completion(text)
                } else {
                    completion(nil)
                }
            }
    }
}

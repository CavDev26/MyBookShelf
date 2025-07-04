import SwiftData
import Firebase
import Foundation

@Model
class Shelf {
    @Attribute(.unique) var id: String
    var name: String
    var latitude: Double?
    var longitude: Double?
    var shelfDescription: String?
    var address: String?
    var needsSync: Bool = false // 👈 aggiunto per il tracking delle modifiche

    @Relationship var books: [SavedBook]

    init(
        name: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        shelfDescription: String? = nil,
        address: String? = nil,
        books: [SavedBook] = [],
        needsSync: Bool = true // 👈 true per default sulle nuove shelf
    ) {
        self.id = UUID().uuidString
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.shelfDescription = shelfDescription
        self.address = address
        self.books = books
        self.needsSync = needsSync
    }
}


class ShelfService {
    static let shared = ShelfService()
    
    private init() {}

    func saveShelf(
        _ shelf: Shelf,
        context: ModelContext,
        userID: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        context.insert(shelf)
        do {
            try context.save()
            print("✅ Saved locally: \(shelf.name)")

            let firestoreData = shelfToFirestoreDict(shelf)
            Firestore.firestore()
                .collection("users")
                .document(userID)
                .collection("shelves")
                .document(shelf.id)
                .setData(firestoreData) { error in
                    if let error = error {
                        print("❌ Firebase upload error: \(error)")
                        completion(.failure(error))
                    } else {
                        print("✅ Uploaded to Firebase")
                        completion(.success(()))
                    }
                }
        } catch {
            print("❌ Local save error: \(error)")
            completion(.failure(error))
        }
    }

    func syncModifiedShelves(userID: String, context: ModelContext) {
        let descriptor = FetchDescriptor<Shelf>(
            predicate: #Predicate { $0.needsSync == true }
        )

        do {
            let dirtyShelves = try context.fetch(descriptor)

            for shelf in dirtyShelves {
                let firestoreData = shelfToFirestoreDict(shelf)
                Firestore.firestore()
                    .collection("users")
                    .document(userID)
                    .collection("shelves")
                    .document(shelf.id)
                    .setData(firestoreData) { error in
                        if let error = error {
                            print("❌ Sync failed: \(error.localizedDescription)")
                        } else {
                            print("✅ Synced shelf: \(shelf.name)")
                            shelf.needsSync = false
                            try? context.save()
                        }
                    }
            }
        } catch {
            print("❌ Fetch failed: \(error)")
        }
    }
    
    func fetchShelvesFromFirebase(userID: String, context: ModelContext, completion: @escaping (Result<[Shelf], Error>) -> Void) {
        Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("shelves")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching shelves: \(error)")
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                var fetchedShelves: [Shelf] = []

                for doc in documents {
                    let data = doc.data()
                    guard let name = data["name"] as? String else { continue }

                    let shelf = Shelf(
                        name: name,
                        latitude: data["latitude"] as? Double,
                        longitude: data["longitude"] as? Double,
                        shelfDescription: data["description"] as? String,
                        address: data["address"] as? String,
                        books: [] // NB: dovrai eventualmente risolvere i SavedBook tramite ID
                    )
                    shelf.id = data["id"] as? String ?? UUID().uuidString
                    shelf.needsSync = false

                    fetchedShelves.append(shelf)
                    context.insert(shelf)
                }

                do {
                    try context.save()
                    print("✅ Saved fetched shelves locally")
                    completion(.success(fetchedShelves))
                } catch {
                    print("❌ Error saving fetched shelves: \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    func deleteShelf(
        _ shelf: Shelf,
        context: ModelContext,
        userID: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // 1. Elimina da Firestore
        Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("shelves")
            .document(shelf.id)
            .delete { error in
                if let error = error {
                    print("❌ Firebase delete error: \(error)")
                    completion(.failure(error))
                    return
                }

                // 2. Elimina da SwiftData
                context.delete(shelf)
                do {
                    try context.save()
                    print("🗑️ Deleted shelf locally: \(shelf.name)")
                    completion(.success(()))
                } catch {
                    print("❌ Local delete error: \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    
    private func shelfToFirestoreDict(_ shelf: Shelf) -> [String: Any] {
        return [
            "id": shelf.id,
            "needsSync": shelf.needsSync,
            "name": shelf.name,
            "latitude": shelf.latitude ?? NSNull(),
            "longitude": shelf.longitude ?? NSNull(),
            "description": shelf.shelfDescription ?? "",
            "address": shelf.address ?? "",
            "bookIDs": shelf.books.map { $0.id } // se vuoi anche i libri
        ]
    }
    
    
    
    func syncShelvesIfNeeded(userID: String, context: ModelContext) {
        let localShelfIDs = (try? context.fetch(FetchDescriptor<Shelf>()).map { $0.id }) ?? []

        Firestore.firestore()
            .collection("users")
            .document(userID)
            .collection("shelves")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("❌ Firebase fetch error: \(error?.localizedDescription ?? "")")
                    return
                }

                let remoteIDs = documents.map { $0.documentID }

                if Set(remoteIDs) != Set(localShelfIDs) {
                    print("🔄 Differenza nelle shelf: inizio sync")
                    self.fetchShelvesFromFirebase(userID: userID, context: context) { _ in }
                } else {
                    print("✅ Shelf già sincronizzate. Nessuna azione necessaria.")
                }
            }
    }
}

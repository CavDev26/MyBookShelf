//
//  FirestoreBook.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 17/06/25.
//


import Foundation
import FirebaseFirestore
import SwiftData
//import FirebaseFirestoreSwift

struct FirestoreBook: Codable, Identifiable {
    var id: String
    var title: String
    var authors: [String]
    var publisher: String
    var coverURL: String?
    var pageCount: Int?
    var bookDescription: String?
    var publishedDate: String?
    var industryIdentifiers: [IndustryIdentifierModel]
    var categories: [String]?
    var mainCategory: String?
    var averageRating: Double?
    var ratingsCount: Int?
    var favourite: Bool

    var readingStatusRaw: String
    var pagesRead: Int
    var userNotes: String
    var rating: Int?
    var genres: [String]?
}

struct FirebaseBookMapper {
    static func toFirestore(_ book: SavedBook) -> FirestoreBook {
        return FirestoreBook(
            id: book.id,
            title: book.title,
            authors: book.authors,
            publisher: book.publisher,
            coverURL: book.coverURL,
            pageCount: book.pageCount,
            bookDescription: book.bookDescription,
            publishedDate: book.publishedDate,
            industryIdentifiers: book.industryIdentifiers,
            categories: book.categories,
            mainCategory: book.mainCategory,
            averageRating: book.averageRating,
            ratingsCount: book.ratingsCount,
            favourite: book.favourite,
            readingStatusRaw: book.readingStatus.rawValue,
            pagesRead: book.pagesRead,
            userNotes: book.userNotes,
            rating: book.rating,
            genres: book.genres?.map { $0.rawValue }
        )
    }

    static func fromFirestore(_ firestoreBook: FirestoreBook) -> SavedBook {
        return SavedBook(
            id: firestoreBook.id,
            title: firestoreBook.title,
            authors: firestoreBook.authors,
            publisher: firestoreBook.publisher,
            coverURL: firestoreBook.coverURL,
            pageCount: firestoreBook.pageCount,
            bookDescription: firestoreBook.bookDescription,
            publishedDate: firestoreBook.publishedDate,
            industryIdentifiers: firestoreBook.industryIdentifiers,
            categories: firestoreBook.categories,
            mainCategory: firestoreBook.mainCategory,
            averageRating: firestoreBook.averageRating,
            ratingsCount: firestoreBook.ratingsCount,
            readingStatus: ReadingStatus(rawValue: firestoreBook.readingStatusRaw) ?? .unread,
            pagesRead: firestoreBook.pagesRead,
            userNotes: firestoreBook.userNotes,
            rating: firestoreBook.rating,
            favourite: firestoreBook.favourite,
            genres: firestoreBook.genres?.compactMap { BookGenre(rawValue: $0) }
        )
    }
}

final class FirebaseBookService {
    static let shared = FirebaseBookService()
    private init() {}

    private let db = Firestore.firestore()

    func upload(book: FirestoreBook, for uid: String) {
        do {
            try db.collection("users").document(uid).collection("books").document(book.id).setData(from: book)
            print("✅ Book uploaded: \(book.title)")
        } catch {
            print("❌ Upload error: \(error.localizedDescription)")
        }
    }
    
    func syncBooksToLocal(for uid: String, context: ModelContext) {
        fetchBooks(for: uid) { firestoreBooks in
            DispatchQueue.main.async {
                do {
                    let existingBooks = try context.fetch(FetchDescriptor<SavedBook>())

                    let firestoreIDs = Set(firestoreBooks.map { $0.id })
                    let localIDs = Set(existingBooks.map { $0.id })

                    // 1. Rimuovi da SwiftData i libri non più presenti su Firestore
                    let booksToDelete = existingBooks.filter { !firestoreIDs.contains($0.id) }
                    for book in booksToDelete {
                        context.delete(book)
                        print("🗑️ Deleted local book not on Firestore: \(book.title)")
                    }

                    // 2. Inserisci nuovi libri da Firestore
                    for fbBook in firestoreBooks {
                        if !localIDs.contains(fbBook.id) {
                            let saved = FirebaseBookMapper.fromFirestore(fbBook)
                            context.insert(saved)
                            print("📥 Inserted new book from Firestore: \(saved.title)")
                        }
                    }

                    try context.save()
                    print("✅ Synced \(firestoreBooks.count) libri da Firestore a SwiftData")

                    let updatedCount = try context.fetch(FetchDescriptor<SavedBook>()).count
                    print("📚 Local SwiftData count after sync: \(updatedCount)")
                } catch {
                    print("❌ Sync save error: \(error)")
                }
            }
        }
    }

    func fetchBooks(for uid: String, completion: @escaping ([FirestoreBook]) -> Void) {
        db.collection("users").document(uid).collection("books").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Fetch error: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let documents = snapshot?.documents else {
                completion([])
                return
            }

            let books = documents.compactMap { doc -> FirestoreBook? in
                return try? doc.data(as: FirestoreBook.self)
            }
            completion(books)
        }
    }

    func deleteBook(bookID: String, for uid: String) {
        db.collection("users").document(uid).collection("books").document(bookID).delete { error in
            if let error = error {
                print("❌ Delete error: \(error.localizedDescription)")
            } else {
                print("🗑️ Book deleted: \(bookID)")
            }
        }
    }
}

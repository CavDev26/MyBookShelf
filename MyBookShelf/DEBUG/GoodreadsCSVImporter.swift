
import Foundation
import SwiftData


struct GoodreadsBook {
    let title: String
    let isbn: String?
    let isbn13: String?
    let myRating: Double?
    let exclusiveShelf: String
    let pagesRead: Int?
}

@MainActor
func importFromLocalCSV(context: ModelContext) async {
    guard let url = Bundle.main.url(forResource: "goodreads_library_export", withExtension: "csv") else {
        print("❌ File non trovato nel bundle")
        return
    }

    do {
        let data = try Data(contentsOf: url)
        guard let content = String(data: data, encoding: .utf8) else { return }

        let rows = content.components(separatedBy: "\n").dropFirst()
        for row in rows {
            let cleanedRow = row.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            let columns = cleanedRow.components(separatedBy: "\",\"")
            guard columns.count > 27 else { continue }

            let title = columns[1]
            let isbn = columns[12].isEmpty ? nil : columns[12]
            let isbn13 = columns[13].isEmpty ? nil : columns[13]
            let myRating = Double(columns[8])
            let shelf = columns[22]
            let pagesRead = Int(columns[27])

            let book = GoodreadsBook(title: title, isbn: isbn, isbn13: isbn13, myRating: myRating, exclusiveShelf: shelf, pagesRead: pagesRead)

            if let bookToSave = await fetchBookFromGoogle(book: book) {
                context.insert(bookToSave)
                try? context.save()
                print("✅ Imported: \(book.title)")
            }
        }
    } catch {
        print("❌ Failed to load local CSV: \(error)")
    }
}

func fetchBookFromGoogle(book: GoodreadsBook) async -> SavedBook? {
    let isbnToUse = book.isbn13 ?? book.isbn
    guard let isbn = isbnToUse, let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)") else {
        return nil
    }
    
    do {
        print("Sto iniziando la fetch: \(isbn)")
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(BooksAPIResponse.self, from: data)
        
        guard let item = decoded.items?.first else { return nil }
        let apiBook = BookAPI(from: item)
        var saved = SavedBook(from: apiBook)
        
        switch book.exclusiveShelf.lowercased() {
        case "read":
            saved.readingStatus = .read
        case "currently-reading":
            saved.readingStatus = .reading
        case "to-read":
            saved.readingStatus = .unread
        default:
            break
        }
        
        if let rating = book.myRating, rating > 0 {
            saved.rating = Int(rating * 2.0) // Goodreads ratings are out of 5, app uses 10
        }
        
        if saved.readingStatus == .reading || saved.readingStatus == .read {
            saved.pagesRead = book.pagesRead ?? 0
        }
        
        return saved
    } catch {
        print("❌ Error fetching book for ISBN \(book.isbn ?? "nil"): \(error)")
        return nil
    }
}

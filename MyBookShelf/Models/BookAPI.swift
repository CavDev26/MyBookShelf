
import Foundation
import SwiftData

struct BookAPI: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let authors: [String]
    let publisher: String
    let coverURL: String?
    let pageCount: Int?
    let description: String?
    let publishedDate: String?
    let industryIdentifiers: [IndustryIdentifier]?
    let categories: [String]?
    let mainCategory: String?
    let averageRating: Double?
    let ratingsCount: Int?
    var detectedGenre: BookGenre {
        BookGenre.detect(from: categories)
    }

    // proprietà personalizzate
    var readingStatus: ReadingStatus = .unread
    var pagesRead: Int? = nil
    var userNotes: String = ""
    var rating: Int? = nil
}

extension BookAPI {
    init(from item: BookItem) {
        self.id = item.id
        self.title = item.volumeInfo.title
        self.authors = item.volumeInfo.authors ?? []
        self.publisher = item.volumeInfo.publisher ?? "Unknown"
        self.coverURL = item.volumeInfo.imageLinks?.thumbnail?.replacingOccurrences(of: "http://", with: "https://")
        self.pageCount = item.volumeInfo.pageCount
        self.description = item.volumeInfo.description
        self.publishedDate = item.volumeInfo.publishedDate
        self.industryIdentifiers = item.volumeInfo.industryIdentifiers
        self.categories = item.volumeInfo.categories
        self.mainCategory = item.volumeInfo.mainCategory
        self.averageRating = item.volumeInfo.averageRating
        self.ratingsCount = item.volumeInfo.ratingsCount
    }
}


struct BookItem: Identifiable, Codable {
    let id: String
    let volumeInfo: VolumeInfo
}

struct VolumeInfo: Codable {
    let title: String
    let authors: [String]?
    let publisher: String?
    let imageLinks: ImageLinks?
    let pageCount: Int?
    let description : String?
    let publishedDate: String?
    let industryIdentifiers: [IndustryIdentifier]?
    let categories: [String]?
    let mainCategory: String?
    let averageRating: Double?
    let ratingsCount: Int?
}

struct IndustryIdentifier: Codable, Equatable, Hashable {
    let type: String
    let identifier: String
}

struct ImageLinks: Codable {
    let thumbnail: String?
}

struct BooksAPIResponse: Codable {
    let items: [BookItem]?
}

enum BookGenre: String, CaseIterable {
    case fantasy
    case sciFi
    case horror
    case romance
    case mystery
    case thriller
    case biography
    case history
    case selfHelp
    case philosophy
    case poetry
    case comics
    case manga
    case youngAdult
    case children
    case classics
    case education
    case unknown
}
extension BookGenre {
    static func from(apiCategory category: String) -> BookGenre {
        let lower = category.lowercased()

        if lower.contains("sci-fi") || lower.contains("science fiction") {
            return .sciFi
        } else if lower.contains("fantasy") {
            return .fantasy
        } else if lower.contains("horror") {
            return .horror
        } else if lower.contains("romance") {
            return .romance
        } else if lower.contains("mystery") || lower.contains("crime") {
            return .mystery
        } else if lower.contains("thriller") || lower.contains("suspense") {
            return .thriller
        } else if lower.contains("biography") || lower.contains("memoir") {
            return .biography
        } else if lower.contains("history") {
            return .history
        } else if lower.contains("self-help") || lower.contains("self improvement") {
            return .selfHelp
        } else if lower.contains("philosophy") {
            return .philosophy
        } else if lower.contains("poetry") {
            return .poetry
        } else if lower.contains("comic") {
            return .comics
        } else if lower.contains("manga") {
            return .manga
        } else if lower.contains("young adult") || lower.contains("ya") {
            return .youngAdult
        } else if lower.contains("children") || lower.contains("kids") {
            return .children
        } else if lower.contains("classic") {
            return .classics
        } else if lower.contains("education") || lower.contains("textbook") {
            return .education
        } else {
            return .unknown
        }
    }

    static func detect(from categories: [String]?) -> BookGenre {
        guard let categories = categories else { return .unknown }
        for cat in categories {
            let genre = from(apiCategory: cat)
            if genre != .unknown {
                return genre
            }
        }
        return .unknown
    }
}

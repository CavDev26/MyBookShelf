
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

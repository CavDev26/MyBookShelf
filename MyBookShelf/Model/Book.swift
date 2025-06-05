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













enum ReadingStatus: String, Codable, Hashable {
    case read
    case unread
    case reading
}

@Model
class Book {
    var id: UUID
    var name: String
    var date: Date
    var tripDescription: String
    var image: String
    var imageUrl: URL? { URL(string: image) }
    var latitude: Double
    var longitude: Double
    var readingStatus: ReadingStatus
    var pages: Int
    var pagesRead: Int

    init(
        id: UUID = UUID(), name: String, date: Date, tripDescription: String,
        image: String, latitude: Double, longitude: Double, readingStatus: ReadingStatus, pages: Int, pagesRead: Int
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.tripDescription = tripDescription
        self.image = image
        self.latitude = latitude
        self.longitude = longitude
        self.readingStatus = readingStatus
        self.pages = pages
        self.pagesRead = pagesRead
    }
}

import Foundation
import SwiftUICore
import SwiftData

@Model
class SavedBook {
    @Attribute(.unique) var id: String
    var title: String
    var authors: [String]
    var publisher: String
    var coverURL: String?
    var pageCount: Int?
    var bookDescription: String?
    var publishedDate: String?
    var industryIdentifiers: [IndustryIdentifierModel] = []
    var categories: [String]?
    var mainCategory: String?
    var averageRating: Double?
    var ratingsCount: Int?
    var favourite: Bool = false

    var readingStatus: ReadingStatus
    var pagesRead: Int
    var userNotes: String
    var rating: Int?
    var genres: [BookGenre]?
    var coverJPG: Data?
    var dateStarted: Date?
    var dateFinished: Date?
    
    init(
        id: String,
        title: String,
        authors: [String],
        publisher: String,
        coverURL: String?,
        pageCount: Int?,
        bookDescription: String?,
        publishedDate: String?,
        industryIdentifiers: [IndustryIdentifierModel],
        categories: [String]?,
        mainCategory: String?,
        averageRating: Double?,
        ratingsCount: Int?,
        readingStatus: ReadingStatus = .unread,
        pagesRead: Int = 0,
        userNotes: String = "",
        rating: Int? = nil,
        favourite: Bool = false,
        genres: [BookGenre]?,
        coverJPG: Data?,
        dateStarted: Date? = nil,
        dateFinished: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.authors = authors
        self.publisher = publisher
        self.coverURL = coverURL
        self.pageCount = pageCount
        self.bookDescription = bookDescription
        self.publishedDate = publishedDate
        self.industryIdentifiers = industryIdentifiers
        self.categories = categories
        self.mainCategory = mainCategory
        self.averageRating = averageRating
        self.ratingsCount = ratingsCount
        self.readingStatus = readingStatus
        self.pagesRead = pagesRead
        self.userNotes = userNotes
        self.rating = rating
        self.favourite = favourite
        self.genres = genres
        self.coverJPG = coverJPG
        self.dateStarted = dateStarted
        self.dateFinished = dateFinished
    }
}

enum ReadingStatus: String, Codable, CaseIterable {
    case all
    case reading
    case read
    case unread

    var color: Color {
        switch self {
        case .unread: return .unreadColor
        case .reading: return .readingColor
        case .read: return .readColor
        case .all: return .gray
        }
    }
    var iconName: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .reading: return "book"
        case .read: return "checkmark.circle"
        case .unread: return "circle"
        }
    }
    static var assignableCases: [ReadingStatus] {
        return [.reading, .read, .unread]
    }
    static var filterableCases: [ReadingStatus] {
        return ReadingStatus.allCases
    }
}


struct IndustryIdentifierModel: Codable, Hashable {
    var type: String
    var identifier: String
}

extension SavedBook {
    convenience init(from book: BookAPI) {
        self.init(
            id: book.id,
            title: book.title,
            authors: book.authors,
            publisher: book.publisher,
            coverURL: book.coverURL,
            pageCount: book.pageCount,
            bookDescription: book.description,
            publishedDate: book.publishedDate,
            industryIdentifiers: book.industryIdentifiers?.map {
                IndustryIdentifierModel(type: $0.type, identifier: $0.identifier)
            } ?? [],
            categories: book.categories ?? [],
            mainCategory: book.mainCategory,
            averageRating: book.averageRating,
            ratingsCount: book.ratingsCount,
            readingStatus: book.readingStatus,
            pagesRead: book.pagesRead ?? 0,
            userNotes: book.userNotes,
            rating: book.rating,
            favourite : false,
            genres: nil,
            coverJPG: nil,
            dateStarted: nil,
            dateFinished: nil
        )
    }
}

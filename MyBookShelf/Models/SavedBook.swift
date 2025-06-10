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
    var industryIdentifiers: [IndustryIdentifierModel]
    var categories: [String]?
    var mainCategory: String?
    var averageRating: Double?
    var ratingsCount: Int?

    var readingStatus: ReadingStatus
    var pagesRead: Int
    var userNotes: String
    var rating: Int?

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
        rating: Int? = nil
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
    }
}

enum ReadingStatus: String, Codable, CaseIterable {
    case read, reading, unread
    
    var color: Color {
        switch self {
        case .unread: return .unreadColor
        case .reading: return .readingColor
        case .read: return .readColor
        }
    }

    var iconName: String {
        switch self {
        case .unread: return "book.closed"
        case .reading: return "book.fill"
        case .read: return "book.closed.fill"
        }
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
            rating: book.rating
        )
    }
}

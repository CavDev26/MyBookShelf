//
//  ExportableBook.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 04/07/25.
//


import Foundation

struct ExportableBook: Codable {
    var id: String
    var title: String
    var authors: [String]
    var publisher: String
    var pageCount: Int?
    var description: String?
    var publishedDate: String?
    var isbn: String?
    var categories: [String]?
    var averageRating: Double?
    var ratingsCount: Int?
    var readingStatus: String
    var pagesRead: Int
    var userNotes: String
    var rating: Int?
    var dateStarted: Date?
    var dateFinished: Date?
}

extension SavedBook {
    func toExportable() -> ExportableBook {
        ExportableBook(
            id: id,
            title: title,
            authors: authors,
            publisher: publisher,
            pageCount: pageCount,
            description: bookDescription,
            publishedDate: publishedDate,
            isbn: industryIdentifiers.first?.identifier,
            categories: categories,
            averageRating: averageRating,
            ratingsCount: ratingsCount,
            readingStatus: readingStatus.rawValue,
            pagesRead: pagesRead,
            userNotes: userNotes,
            rating: rating,
            dateStarted: dateStarted,
            dateFinished: dateFinished
        )
    }
}

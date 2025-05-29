//
//  Trip.swift
//  TravelDiary
//
//  Created by Gianni Tumedei on 07/05/25.
//

import Foundation
import SwiftData

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

    init(
        id: UUID = UUID(), name: String, date: Date, tripDescription: String,
        image: String, latitude: Double, longitude: Double, readingStatus: ReadingStatus
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.tripDescription = tripDescription
        self.image = image
        self.latitude = latitude
        self.longitude = longitude
        self.readingStatus = readingStatus
    }
}

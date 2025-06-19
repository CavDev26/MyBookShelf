import SwiftData
import Foundation

@Model
class Shelf {
    @Attribute(.unique) var id: String
    var name: String
    var latitude: Double?
    var longitude: Double?
    var shelfDescription: String?
    var address: String? // opzionale, per inserimento manuale

    @Relationship var books: [SavedBook]

    init(name: String, latitude: Double? = nil, longitude: Double? = nil, shelfDescription: String? = nil, address: String? = nil, books: [SavedBook] = []) {
        self.id = UUID().uuidString
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.shelfDescription = shelfDescription
        self.address = address
        self.books = books
    }
}

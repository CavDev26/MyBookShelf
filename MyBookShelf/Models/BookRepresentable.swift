protocol BookRepresentable {
    var id: String { get }
    var title: String { get }
    var authors: [String] { get }
    var publisher: String { get }
    var coverURL: String? { get }
    var pageCount: Int? { get }
    var descriptionText: String? { get }
    var publishedDate: String? { get }
    var categories: [String]? { get }
    var averageRating: Double? { get }
    var ratingsCount: Int? { get }
    var genres: [BookGenre]? { get }
}

// MARK: - Estensioni di conformità

extension BookAPI: BookRepresentable {
    var genres: [BookGenre]? {nil}
    
    var descriptionText: String? { description }
}

extension SavedBook: BookRepresentable {
    var descriptionText: String? { bookDescription }
}

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
    //var genre: BookGenre?
}

extension BookAPI {
    init(from item: BookItem, genre: BookGenre = .unknown) {
        self.id = item.id
        self.title = item.volumeInfo.title
        self.authors = item.volumeInfo.authors ?? []
        self.publisher = item.volumeInfo.publisher ?? "Unknown"
        //self.coverURL = item.volumeInfo.bestCoverURL()?
        //.absoluteString.replacingOccurrences(of: "http://", with: "https://")
        self.coverURL = item.volumeInfo.imageLinks?.thumbnail?.replacingOccurrences(of: "http://", with: "https://")
        self.pageCount = item.volumeInfo.pageCount
        self.description = item.volumeInfo.description
        self.publishedDate = item.volumeInfo.publishedDate
        self.industryIdentifiers = item.volumeInfo.industryIdentifiers
        self.categories = item.volumeInfo.categories
        self.mainCategory = item.volumeInfo.mainCategory
        self.averageRating = item.volumeInfo.averageRating
        self.ratingsCount = item.volumeInfo.ratingsCount
        //self.genre = genre
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

/*extension VolumeInfo {
 func bestCoverURL() -> URL? {
 guard let links = self.imageLinks else { return nil }
 if let x = links.extraLarge ?? links.large ?? links.medium ?? links.small{
 
 print("sto facendo gl iextralarge ecc \(x)")
 return URL(string: x)
 }
 if let thumb = links.thumbnail {
 print("sto facendo la thumb")
 
 let hiRes = thumb
 .replacingOccurrences(of: "zoom=1", with: "zoom=10") + "&fife=w800-h1200"
 return URL(string: hiRes.isEmpty ? thumb : hiRes)
 }
 return nil
 }
 }*/

struct IndustryIdentifier: Codable, Equatable, Hashable {
    let type: String
    let identifier: String
}

struct ImageLinks: Codable {
    let smallThumbnail: String?
    let thumbnail: String?
    let small: String?
    let medium: String?
    let large: String?
    let extraLarge: String?
}

struct BooksAPIResponse: Codable {
    let items: [BookItem]?
}

enum BookGenre: String, CaseIterable, Codable {
    case love = "love"
    case scienceFiction = "science-fiction"
    case fantasy = "fantasy"
    case horror = "horror"
    case mystery = "mystery"
    case historicalFiction = "historical-fiction"
    case thriller = "thriller"
    case romance = "romance"
    case poetry = "poetry"
    case youngAdult = "young-adult"
    case children = "children"
    case pictureBooks = "picture-books"
    case biography = "biographies"
    case history = "history"
    case science = "science"
    case mathematics = "mathematics"
    case psychology = "psychology"
    case philosophy = "philosophy"
    case religion = "religion"
    case cooking = "cooking"
    case health = "health"
    case selfHelp = "self-help"
    case education = "education"
    case art = "art"
    case music = "music"
    case photography = "photography"
    case animals = "animals"
    case cats = "cats"
    case dogs = "dogs"
    case sports = "sports"
    case travel = "travel"
    case computers = "computers"
    case programming = "programming"
    case textbooks = "textbooks"
    case literature = "literature"
    case unknown = "unknown"
}

extension BookGenre {
    static func fromImageName(_ imageName: String) -> BookGenre {
        switch imageName.lowercased() {
        case "scifi": return .scienceFiction
        case "comics": return .art
        case "horror": return .horror
        case "mistery": return .mystery
        case "fantasy": return .fantasy
        case "classics": return .literature
        default: return .unknown
        }
    }
    
    
    
    static func fromOpenLibrarySubject(_ subject: String) -> BookGenre? {
        let normalized = subject.lowercased().replacingOccurrences(of: " ", with: "-")
        
        let mapping: [String: BookGenre] = [
            "science-fiction": .scienceFiction,
            "fantasy": .fantasy,
            "horror": .horror,
            "mystery": .mystery,
            "historical-fiction": .historicalFiction,
            "thriller": .thriller,
            "romance": .romance,
            "poetry": .poetry,
            "young-adult": .youngAdult,
            "children": .children,
            "picture-books": .pictureBooks,
            "biography": .biography,
            "biographies": .biography,
            "history": .history,
            "science": .science,
            "mathematics": .mathematics,
            "psychology": .psychology,
            "philosophy": .philosophy,
            "religion": .religion,
            "cooking": .cooking,
            "health": .health,
            "self-help": .selfHelp,
            "education": .education,
            "art": .art,
            "music": .music,
            "photography": .photography,
            "animals": .animals,
            "cats": .cats,
            "dogs": .dogs,
            "sports": .sports,
            "travel": .travel,
            "computers": .computers,
            "programming": .programming,
            "textbooks": .textbooks,
            "literature": .literature,
            "love": .love,
            "unknown" : .unknown
        ]
        
        return mapping[normalized]
    }
    
}

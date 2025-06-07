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
    
    /*var detectedGenres: [BookGenre] {
        BookGenre.detectAll(from: categories, description: description)
    }*/

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
    case unknown = "unknown"
    
    
    /*case fiction, sciFi, horror, romance, mystery, thriller, biography, history, selfHelp, philosophy, poetry, comics, manga, youngAdult, children, classics, education, unknown*/
}

/*extension BookGenre {
    static func from(apiCategory category: String) -> BookGenre {
        let lower = category.lowercased()
        if lower.contains("sci-fi") || lower.contains("science fiction") {
            return .sciFi
        } else if lower.contains("fantasy") {
            return .fiction
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

    /*static func detectAll(from categories: [String]?, description: String?) -> [BookGenre] {
        var detected: Set<BookGenre> = []

        if let categories = categories {
            for cat in categories {
                let genre = from(apiCategory: cat)
                if genre != .unknown {
                    detected.insert(genre)
                }
            }
        }

        if let description = description?.lowercased() {
            let keywordMapping: [BookGenre: [String]] = [
                .horror: ["horror", "ghost", "ghosts", "haunted", "vampire", "vampires", "zombie", "zombies", "creepy", "terror", "paura", "spavento", "mostro", "mostri", "orrore", "fantasma", "fantasmi", "inquietante", "terrore", "brivido"],
                .fiction: ["magic", "magical", "dragon", "dragons", "wizard", "wizards", "fantasy", "sword", "swords", "kingdom", "kingdoms", "elf", "elves", "monster", "monsters", "spell", "mythical", "quest", "realm", "castle", "castles", "incantesimo", "magia", "magico", "fantastico", "regno", "epica", "epico", "castello", "castelli", "drago", "draghi"],
                .sciFi: ["space", "alien", "aliens", "robot", "robots", "sci-fi", "science fiction", "future", "futuristic", "technology", "cyborg", "android", "interstellar", "spaceship", "galaxy", "universo", "spazio", "futuro", "tecnologia", "robotico", "intelligenza artificiale", "cyberpunk"],
                .romance: ["love", "romance", "relationship", "relationships", "affair", "affairs", "passion", "heart", "hearts", "kiss", "kisses", "wedding", "marriage", "couple", "dating", "innamorati", "amore", "cuore", "cuori", "relazione", "relazioni", "matrimonio", "sposi", "fidanzati", "passione", "bacio", "baci"],
                .mystery: ["mystery", "mysteries", "detective", "murder", "crime", "investigation", "whodunit", "clue", "suspect", "case", "mistero", "omicidio", "indagine", "indagini", "crimine", "delitto", "sospetto", "detective", "enigma"],
                .thriller: ["thriller", "suspense", "conspiracy", "espionage", "spy", "chase", "danger", "plot", "intensity", "adrenaline", "pericolo", "cospirazione", "spionaggio", "fuga", "rincorsa", "tensione", "trama", "azione", "intenso", "death", "morte", "sangue", "blood"],
                .biography: ["biography", "memoir", "life of", "autobiography", "story of", "real life", "personal history", "true story", "biografia", "memorie", "vita di", "autobiografia", "storia vera", "racconto di vita", "personaggio reale"],
                .history: ["history", "historical", "past", "ancient", "civilization", "empire", "war", "wars", "battle", "timeline", "storia", "storico", "antico", "civiltà", "battaglia", "guerra", "imperi", "cronologia", "passato", "medioevo"],
                .selfHelp: ["self-help", "motivation", "inspiration", "personal growth", "guide", "coaching", "wellness", "happiness", "mental health", "auto-aiuto", "motivazione", "ispirazione", "crescita personale", "benessere", "felicità", "salute mentale", "guida"],
                .philosophy: ["philosophy", "thought", "ethics", "metaphysics", "logic", "wisdom", "existence", "reality", "morality", "filosofia", "pensiero", "etica", "logica", "realtà", "saggezza", "esistenza", "morale", "metafisica"],
                .poetry: ["poetry", "poem", "poems", "verse", "verses", "sonnet", "haiku", "rhyme", "lyric", "poesia", "poesie", "verso", "versi", "rima", "lirica", "sonetto"],
                .comics: ["comic", "comics", "graphic novel", "illustrated", "superhero", "superheroes", "strip", "fumetto", "fumetti", "illustrato", "supereroe", "supereroi", "vignette", "manga"],
                .manga: ["manga", "anime", "japanese comic", "shonen", "shojo", "otaku", "illustrated japan", "fumetto giapponese", "giappone", "cartone giapponese", "anime"],
                .youngAdult: ["young adult", "teen", "ya", "coming of age", "high school", "adolescente", "liceo", "giovani", "formazione", "giovinezza", "teenager", "scuola", "amicizia", "crescita", "drama adolescenziale"],
                .children: ["children", "kids", "storybook", "picture book", "fairy tale", "infanzia", "bambini", "fiaba", "libro illustrato", "favola", "racconto per bambini", "piccoli", "ninna nanna"],
                .classics: ["classic", "literature", "masterpiece", "timeless", "canonical", "great novel", "eterno", "capolavoro", "letteratura", "romanzo storico", "romanzo classico", "opera d'arte", "autore classico"],
                .education: ["education", "textbook", "learning", "study", "curriculum", "homework", "school", "lezione", "apprendimento", "educazione", "istruzione", "manuale", "studio", "scuola", "università", "insegnamento"]
            ]

            for (genre, keywords) in keywordMapping {
                if keywords.contains(where: { description.contains($0) }) {
                    detected.insert(genre)
                }
            }
        }

        return detected.isEmpty ? [.unknown] : Array(detected)
    }*/
}*/

/*extension BookGenre {
    var googleSubject: String {
        switch self {
        case .sciFi: return "sciFi"
        case .youngAdult: return "youngAdult"
        case .selfHelp: return "self-help"
        case .comics: return "comics & graphic novels"
        case .classics: return "literary collections"
        case .biography: return "biography & autobiography"
        case .history: return "history"
        case .philosophy: return "philosophy"
        case .poetry: return "poetry"
        case .manga: return "manga"
        case .thriller: return "thrillers"
        case .mystery: return "mystery"
        case .romance: return "romance"
        case .fiction: return "fiction"
        case .horror: return "horror"
        case .children: return "juvenile fiction"
        case .education: return "education"
        case .unknown: return ""
        }
    }
}*/

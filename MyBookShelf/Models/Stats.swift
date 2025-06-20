import Foundation
import SwiftData

@Model
class GlobalReadingStats {
    var totalBooksFinished: Int
    var totalPagesRead: Int
    var longestBookRead: Int // in pagine
    var mostBooksReadInAYear: Int
    var mostBooksReadInAMonth: Int
    var totalXP: Int


    init(totalBooksFinished: Int = 0, totalPagesRead: Int = 0, longestBookRead: Int = 0, mostBooksReadInAYear: Int = 0, mostBooksReadInAMonth: Int = 0, totalXP: Int = 0) {
        self.totalBooksFinished = totalBooksFinished
        self.totalPagesRead = totalPagesRead
        self.longestBookRead = longestBookRead
        self.mostBooksReadInAYear = mostBooksReadInAMonth
        self.mostBooksReadInAMonth = mostBooksReadInAMonth
        self.totalXP = totalXP
    }
}

@Model
class YearlyReadingChallenge {
    var year: Int
    var goal: Int
    var booksFinished: Int
    var isCompleted: Bool
    var completionDate: Date?

    init(year: Int, goal: Int, booksFinished: Int = 0) {
        self.year = year
        self.goal = goal
        self.booksFinished = booksFinished
        self.isCompleted = false
        self.completionDate = nil
    }
}

@Model
class MonthlyReadingChallenge {
    var year: Int
    var month: Int // 1-12
    var goal: Int
    var booksFinished: Int
    var isCompleted: Bool
    var completionDate: Date?

    init(year: Int, month: Int, goal: Int, booksFinished: Int = 0) {
        self.year = year
        self.month = month
        self.goal = goal
        self.booksFinished = booksFinished
        self.isCompleted = false
        self.completionDate = nil
    }
}

/*enum BadgeType: String, Codable {
    case global
    case yearly
    case monthly
    case streak
}

@Model
class Badge {
    var id: String
    var name: String
    var badgeDescription: String
    var earnedDate: Date?
    var isEarned: Bool
    var type: String // BadgeType.rawValue

    init(id: String, name: String, description: String, type: BadgeType, isEarned: Bool = false, earnedDate: Date? = nil) {
        self.id = id
        self.name = name
        self.badgeDescription = description
        self.type = type.rawValue
        self.isEarned = isEarned
        self.earnedDate = earnedDate
    }
}*/





///FIREBASE SECTION
///
struct FirestoreGlobalReadingStats: Codable {
    var totalBooksFinished: Int
    var totalPagesRead: Int
    var longestBookRead: Int
    var mostBooksReadInAYear: Int
    var mostBooksReadInAMonth: Int
    var experiencePoints: Int
    
    var startDate: Date
    var lastUpdate: Date
}

struct FirestoreYearlyReadingChallenge: Codable, Identifiable {
    var id: String { "\(year)" } // es: "2025"
    
    var year: Int
    var goal: Int
    var booksFinished: Int
    var isCompleted: Bool
    var completionDate: Date?
}
struct FirestoreMonthlyReadingChallenge: Codable, Identifiable {
    var id: String { "\(year)-\(month)" } // es: "2025-6"
    
    var year: Int
    var month: Int
    var goal: Int
    var booksFinished: Int
    var isCompleted: Bool
    var completionDate: Date?
}


/*enum FirestoreBadgeType: String, Codable {
    case global
    case yearly
    case monthly
    case streak
}

struct FirestoreBadge: Codable, Identifiable {
    var id: String
    var name: String
    var description: String
    var earnedDate: Date?
    var isEarned: Bool
    var type: FirestoreBadgeType
}*/

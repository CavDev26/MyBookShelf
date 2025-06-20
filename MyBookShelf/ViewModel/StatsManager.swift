//
//  StatsManager.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 20/06/25.
//

import Foundation
import SwiftData


@MainActor
class StatsManager: ObservableObject {
    static let shared = StatsManager()
    
    func updateStats(using books: [SavedBook], in context: ModelContext) {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)

        let finishedBooks = books.filter { $0.readingStatus == .read }

        // 📊 Global Stats
        if let stats = try? context.fetch(FetchDescriptor<GlobalReadingStats>()).first {
            stats.totalBooksFinished = finishedBooks.count
            stats.totalPagesRead = finishedBooks.compactMap { $0.pageCount }.reduce(0, +)
            stats.longestBookRead = finishedBooks.compactMap { $0.pageCount }.max() ?? 0

            let booksByYear = Dictionary(grouping: finishedBooks.compactMap { $0.dateFinished }) {
                calendar.component(.year, from: $0)
            }
            stats.mostBooksReadInAYear = booksByYear.mapValues { $0.count }.values.max() ?? 0

            let booksByMonth = Dictionary(grouping: finishedBooks.compactMap { $0.dateFinished }) {
                let comps = calendar.dateComponents([.year, .month], from: $0)
                return "\(comps.year!)-\(comps.month!)"
            }
            stats.mostBooksReadInAMonth = booksByMonth.mapValues { $0.count }.values.max() ?? 0
        }

        // 📆 Yearly Challenge
        let booksThisYear = finishedBooks.filter {
            guard let date = $0.dateFinished else { return false }
            return calendar.component(.year, from: date) == currentYear
        }

        let yearlyChallenge = try? context.fetch(FetchDescriptor<YearlyReadingChallenge>())
            .first(where: { $0.year == currentYear }) ?? {
                let new = YearlyReadingChallenge(year: currentYear, goal: 0)
                context.insert(new)
                return new
            }()
        yearlyChallenge?.booksFinished = booksThisYear.count
        if let yc = yearlyChallenge, yc.goal > 0 && yc.booksFinished >= yc.goal {
            yc.isCompleted = true
            yc.completionDate = yc.completionDate ?? now
        }

        // 📅 Monthly Challenge
        let booksThisMonth = booksThisYear.filter {
            guard let date = $0.dateFinished else { return false }
            return calendar.component(.month, from: date) == currentMonth
        }

        let monthlyChallenge = try? context.fetch(FetchDescriptor<MonthlyReadingChallenge>())
            .first(where: { $0.year == currentYear && $0.month == currentMonth }) ?? {
                let new = MonthlyReadingChallenge(year: currentYear, month: currentMonth, goal: 0)
                context.insert(new)
                return new
            }()
        monthlyChallenge?.booksFinished = booksThisMonth.count
        if let mc = monthlyChallenge, mc.goal > 0 && mc.booksFinished >= mc.goal {
            mc.isCompleted = true
            mc.completionDate = mc.completionDate ?? now
        }

        try? context.save()
    }
}



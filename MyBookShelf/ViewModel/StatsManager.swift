//
//  StatsManager.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 20/06/25.
//
import Foundation
import FirebaseFirestore
import SwiftData

@MainActor
class StatsManager: ObservableObject {
    static let shared = StatsManager()
    
    func updateStats(using books: [SavedBook], in context: ModelContext, uid: String) {
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
            
            // 🆕 XP Calculation
            let xpFromPages = stats.totalPagesRead / 10
            let monthlyCompleted = (try? context.fetch(FetchDescriptor<MonthlyReadingChallenge>()).filter { $0.isCompleted }.count) ?? 0
            let yearlyCompleted = (try? context.fetch(FetchDescriptor<YearlyReadingChallenge>()).first(where: { $0.year == currentYear })?.isCompleted) == true
            let xpFromMonths = monthlyCompleted * 25
            let xpFromYear = yearlyCompleted ? 100 : 0
            stats.totalXP = xpFromPages + xpFromMonths + xpFromYear
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
        Task {
            await self.syncStatsToFirebase(for: uid, from: context)
            await self.syncChallengesToFirebase(for: uid, from: context)
            if let stats = try? context.fetch(FetchDescriptor<GlobalReadingStats>()).first {
                self.updateLevelOnFirebase(for: uid, xp: stats.totalXP)
            }
        }
    }
    
    func updateLevelOnFirebase(for uid: String, xp: Int) {
        let level = xp / 100
        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.setData(["level": level], merge: true) { error in
            if let error = error {
                print("❌ Errore aggiornamento livello: \(error.localizedDescription)")
            } else {
                print("✅ Livello Firebase aggiornato a \(level)")
            }
        }
    }
}



extension StatsManager {
    
    func fetchChallengesFromFirebase(for uid: String, context: ModelContext) async {
        let ref = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("stats")
        
        do {
            let yearlyDocs = try await ref.getDocuments()
            
            
            for doc in yearlyDocs.documents {
                let id = doc.documentID
                
                if id.contains("-") {
                    // ➕ È una MonthlyChallenge
                    if let m = try? doc.data(as: FirestoreMonthlyReadingChallenge.self) {
                        let model = MonthlyReadingChallenge(
                            year: m.year,
                            month: m.month,
                            goal: m.goal,
                            booksFinished: m.booksFinished
                        )
                        model.isCompleted = m.isCompleted
                        model.completionDate = m.completionDate
                        print("📘 Monthly trovato: \(model.goal)")
                        context.insert(model)
                    }
                } else {
                    // ➕ È una YearlyChallenge
                    if let y = try? doc.data(as: FirestoreYearlyReadingChallenge.self) {
                        let model = YearlyReadingChallenge(
                            year: y.year,
                            goal: y.goal,
                            booksFinished: y.booksFinished
                        )
                        model.isCompleted = y.isCompleted
                        model.completionDate = y.completionDate
                        print("📗 Yearly trovato: \(model.goal)")
                        context.insert(model)
                    }
                }
            }
            
            
            /*for doc in yearlyDocs.documents {
             if let y = try? doc.data(as: FirestoreYearlyReadingChallenge.self) {
             let model = YearlyReadingChallenge(
             year: y.year,
             goal: y.goal,
             booksFinished: y.booksFinished
             )
             model.isCompleted = y.isCompleted
             model.completionDate = y.completionDate
             print("Yearly trovato: \(model.goal)")
             context.insert(model)
             } else if let m = try? doc.data(as: FirestoreMonthlyReadingChallenge.self) {
             let model = MonthlyReadingChallenge(
             year: m.year,
             month: m.month,
             goal: m.goal,
             booksFinished: m.booksFinished
             )
             model.isCompleted = m.isCompleted
             model.completionDate = m.completionDate
             print("Monthly trovato: \(model.goal)")
             context.insert(model)
             }
             }*/
            
            try? context.save()
            print("✅ Challenges fetched from Firebase")
        } catch {
            print("❌ Error fetching challenges from Firebase: \(error)")
        }
    }
    func syncChallengesToFirebase(for uid: String, from context: ModelContext) async {
        do {
            let yearly = try context.fetch(FetchDescriptor<YearlyReadingChallenge>())
            let monthly = try context.fetch(FetchDescriptor<MonthlyReadingChallenge>())
            
            let statsRef = Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("stats")
            
            for y in yearly {
                let data = FirestoreYearlyReadingChallenge(
                    year: y.year,
                    goal: y.goal,
                    booksFinished: y.booksFinished,
                    isCompleted: y.isCompleted,
                    completionDate: y.completionDate
                )
                try await statsRef.document("\(y.year)").setData(from: data)
            }
            
            for m in monthly {
                let data = FirestoreMonthlyReadingChallenge(
                    year: m.year,
                    month: m.month,
                    goal: m.goal,
                    booksFinished: m.booksFinished,
                    isCompleted: m.isCompleted,
                    completionDate: m.completionDate
                )
                try await statsRef.document("\(m.year)-\(m.month)").setData(from: data)
            }
            
            print("✅ Challenges synced to Firebase")
            
        } catch {
            print("❌ Error syncing challenges to Firebase: \(error)")
        }
    }
    
    func syncStatsToFirebase(for uid: String, from context: ModelContext) async {
        guard let stats = try? context.fetch(FetchDescriptor<GlobalReadingStats>()).first else { return }
        
        let firestoreStats = FirestoreGlobalReadingStats(
            totalBooksFinished: stats.totalBooksFinished,
            totalPagesRead: stats.totalPagesRead,
            longestBookRead: stats.longestBookRead,
            mostBooksReadInAYear: stats.mostBooksReadInAYear,
            mostBooksReadInAMonth: stats.mostBooksReadInAMonth,
            experiencePoints: stats.totalXP,
            startDate: .now, // Puoi anche salvarlo solo al primo avvio
            lastUpdate: .now
        )
        
        do {
            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("stats")
                .document("global")
                .setData(from: firestoreStats)
            print("✅ Stats synced to Firebase")
        } catch {
            print("❌ Error syncing stats to Firebase: \(error)")
        }
    }
    
    func fetchStatsFromFirebase(for uid: String, context: ModelContext) async {
        let docRef = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("stats")
            .document("global")
        
        do {
            let snapshot = try await docRef.getDocument()
            if let data = try? snapshot.data(as: FirestoreGlobalReadingStats.self) {
                let stats = GlobalReadingStats(
                    totalBooksFinished: data.totalBooksFinished,
                    totalPagesRead: data.totalPagesRead,
                    longestBookRead: data.longestBookRead,
                    mostBooksReadInAYear: data.mostBooksReadInAYear,
                    mostBooksReadInAMonth: data.mostBooksReadInAMonth,
                    totalXP: data.experiencePoints
                )
                print("📥 Dati stats ricevuti da Firebase:")
                print("📘 Totale libri finiti: \(data.totalBooksFinished)")
                print("📄 Pagine lette: \(data.totalPagesRead)")
                context.insert(stats)
                try? context.save()
                print("✅ Stats fetched from Firebase")
            }
        } catch {
            print("❌ Error fetching stats from Firebase: \(error)")
        }
    }
}

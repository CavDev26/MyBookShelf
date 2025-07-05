//
//  WatchSessionManager.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 21/06/25.
//


import Foundation
import WatchConnectivity
import SwiftUI
import SwiftData

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    private var handledTimestamps: Set<TimeInterval> = []
    static let shared = WatchSessionManager()
    private var authManager: AuthManager?
    private var modelContext: ModelContext?
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    func setAuthManager(_ auth: AuthManager) {
        self.authManager = auth
    }

    private override init() {
        super.init()
        activateSession()
    }

    func activateSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("❌ Watch session activation failed: \(error.localizedDescription)")
        } else {
            print("✅ Watch session activated: \(activationState.rawValue)")
        }
    }

    /*func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleIncomingData(message)
    }*/

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        handleIncomingData(userInfo)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if message["requestReadingBooks"] as? Bool == true {
            print("📥 Ricevuta richiesta libri dal Watch")
            sendCurrentReadingBooks()
        } else {
            handleIncomingData(message)
        }
    }
    

    /*private func handleIncomingData(_ data: [String: Any]) {
        guard let type = data["type"] as? String else { return }

        if type == "readingSession" {
            let minutes = data["durationMinutes"] as? Int ?? 0
            let timestamp = data["timestamp"] as? TimeInterval ?? Date().timeIntervalSince1970
            let date = Date(timeIntervalSince1970: timestamp)

            print("📩 Sessione di lettura ricevuta: \(minutes) minuti alle \(date)")

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .readingSessionReceived, object: nil, userInfo: [
                    "duration": minutes,
                    "timestamp": date
                ])

                // ⬇️ Notifica locale
                self.showReadingSessionNotification(minutes: minutes, at: date)
            }
        }
    }*/
    
    
    
    private func handleIncomingData(_ data: [String: Any]) {
        
        guard let type = data["type"] as? String, type == "readingSession" else { return }

        let timestamp = data["timestamp"] as? TimeInterval ?? Date().timeIntervalSince1970

        // 🛑 Evita duplicati
        guard !handledTimestamps.contains(timestamp) else {
            print("⚠️ Sessione già gestita, ignorata")
            return
        }
        handledTimestamps.insert(timestamp)
        
        
        
        
        let minutes = data["durationMinutes"] as? Int ?? 0
        //let timestamp = data["timestamp"] as? TimeInterval ?? Date().timeIntervalSince1970
        let page = data["pagesRead"] as? Int
        let bookIDString = data["bookID"] as? String
        let date = Date(timeIntervalSince1970: timestamp)
        let title = data["title"] as? String ?? ""

        DispatchQueue.main.async {
            guard let modelContext = self.modelContext,
                  let bookID = bookIDString else {
                print("❌ BookID non valido")
                return
            }
            
            let descriptor = FetchDescriptor<SavedBook>()
            if let books = try? modelContext.fetch(descriptor),
               let book = books.first(where: { $0.id == bookID }) {
                let pcount = book.pageCount ?? 0
                if let newPage = page {
                    if newPage >= pcount {
                        book.pagesRead = pcount
                        book.readingStatus = .read
                    } else {
                        book.pagesRead = newPage
                    }
                    try? modelContext.save()

                    // 🔁 Sync Firebase
                    FirebaseBookService.shared.upload(
                        book: FirebaseBookMapper.toFirestore(book),
                        for: self.authManager?.uid ?? ""
                    )
                }

                NotificationCenter.default.post(name: .readingSessionReceived, object: nil, userInfo: [
                    "duration": minutes,
                    "timestamp": date,
                    "title": title,
                    "pagesRead": page ?? 0
                ])

                self.showReadingSessionNotification(minutes: minutes, title: title, at: date, page: page ?? 0)
            }
        }
    }
    
    
    
    func showReadingSessionNotification(minutes: Int, title: String, at date: Date, page: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Apple Watch Reading Session"
        content.body = "Read \(title), for \(minutes) minutes.\nYou are now at page \(page)!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Errore invio notifica: \(error.localizedDescription)")
            }
        }
    }
    
    private func sendCurrentReadingBooks() {
        guard let modelContext = modelContext else { return }

        let descriptor = FetchDescriptor<SavedBook>()
        guard let books = try? modelContext.fetch(descriptor) else {
            print("❌ Impossibile fetchare i libri da SwiftData")
            return
        }

        let readingBooks = books.filter { $0.readingStatus == .reading }

        let watchBooks: [WatchBook] = readingBooks.map {
            WatchBook(
                id: $0.id,
                title: $0.title,
                author: $0.authors.joined(separator: ", "),
                coverData: $0.coverURL
            )
        }

        guard let encoded = try? JSONEncoder().encode(watchBooks) else {
            print("❌ Encoding fallito")
            return
        }

        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["readingBooks": encoded], replyHandler: nil) { error in
                print("❌ Errore invio libri: \(error.localizedDescription)")
            }
        } else {
            print("⚠️ Watch non raggiungibile al momento")
        }
    }
    
    

    func sendReadingBooksToWatch(from books: [SavedBook]) {
        // Filtra solo i libri in lettura
        let reading = books.filter { $0.readingStatus == .reading }

        // Mappa in WatchBook
        let watchBooks: [WatchBook] = reading.map { book in
            WatchBook(
                id: book.id,
                title: book.title,
                author: book.authors.joined(separator: ", "),
                coverData: book.coverURL // se hai immagini locali
            )
        }

        // Codifica in Data
        guard let encoded = try? JSONEncoder().encode(watchBooks) else {
            print("❌ Errore encoding libri")
            return
        }

        // Invia al Watch
        if WCSession.default.isPaired && WCSession.default.isWatchAppInstalled {
            WCSession.default.transferUserInfo(["readingBooks": encoded])
            print("📤 Libri in lettura inviati al Watch (\(reading.count))")
        } else {
            print("⚠️ Watch non collegato o app non installata")
        }
    }
    
}

extension Notification.Name {
    static let readingSessionReceived = Notification.Name("readingSessionReceived")
}




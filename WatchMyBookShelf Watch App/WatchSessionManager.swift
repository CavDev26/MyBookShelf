//
//  WatchSessionManager.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 21/06/25.
//


import Foundation
import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate, ObservableObject {
    
    static let shared = WatchSessionManager()
    @Published var readingBooks: [WatchBook] = []

    override init() {
        super.init()
        activateSession()
    }

    func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("🟢 Watch session activated")
        }
    }
    
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let booksData = userInfo["readingBooks"] as? Data {
            if let decoded = try? JSONDecoder().decode([WatchBook].self, from: booksData) {
                DispatchQueue.main.async {
                    self.readingBooks = decoded
                    print("📥 Libri ricevuti via transferUserInfo: \(decoded.count)")
                }
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let booksData = message["readingBooks"] as? Data {
            if let decoded = try? JSONDecoder().decode([WatchBook].self, from: booksData) {
                DispatchQueue.main.async {
                    self.readingBooks = decoded
                    print("📥 Libri ricevuti via sendMessage: \(decoded.count)")
                }
            }
        } else {
            print("⚠️ Messaggio ricevuto ma chiave 'readingBooks' non trovata")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("❌ Watch session activation failed: \(error.localizedDescription)")
        } else {
            print("✅ Watch session state: \(activationState.rawValue)")
        }
    }
    
    func requestReadingBooks() {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["requestReadingBooks": true], replyHandler: nil, errorHandler: { error in
                print("❌ Errore richiesta libri: \(error.localizedDescription)")
            })
        }
    }
    
}

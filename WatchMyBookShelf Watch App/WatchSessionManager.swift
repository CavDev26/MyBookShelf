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
                }
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("❌ Watch session activation failed: \(error.localizedDescription)")
        } else {
            print("✅ Watch session state: \(activationState.rawValue)")
        }
    }

    // Puoi anche aggiungere altri metodi WCSessionDelegate se ti servono
}

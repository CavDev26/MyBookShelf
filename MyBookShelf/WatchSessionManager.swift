//
//  WatchSessionManager.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 21/06/25.
//


import Foundation
import WatchConnectivity
import SwiftUI

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    static let shared = WatchSessionManager()

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

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleIncomingData(message)
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        handleIncomingData(userInfo)
    }

    private func handleIncomingData(_ data: [String: Any]) {
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
    }
    func showReadingSessionNotification(minutes: Int, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "📚 Lettura completata!"
        content.body = "Hai letto per \(minutes) minuti."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Errore invio notifica: \(error.localizedDescription)")
            }
        }
    }
}

extension Notification.Name {
    static let readingSessionReceived = Notification.Name("readingSessionReceived")
}

import Foundation

struct ReadingNotification: Identifiable, Hashable {
    let id = UUID()
    let notName: String
    let message: String
    let timestamp: Date
}


class NotificationViewModel: ObservableObject {
    @Published var notifications: [ReadingNotification] = []

    /*func addNotification(_ notification: ReadingNotification) {
        notifications.insert(notification, at: 0) // mostre le più recenti in cima
    }*/
    
    
    func addNotification(_ notification: ReadingNotification) {
        // Evita duplicati usando timestamp e/o messaggio
        if notifications.contains(where: {
            $0.timestamp == notification.timestamp &&
            $0.message == notification.message
        }) {
            print("⚠️ Notifica già presente, ignorata")
            return
        }

        notifications.append(notification)
        // Ordina le notifiche (opzionale)
        notifications.sort(by: { $0.timestamp > $1.timestamp })
    }
}


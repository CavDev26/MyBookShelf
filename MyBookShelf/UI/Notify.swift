import Foundation

struct ReadingNotification: Identifiable, Hashable {
    let id = UUID()
    let notName: String
    let message: String
    let timestamp: Date
}


class NotificationViewModel: ObservableObject {
    @Published var notifications: [ReadingNotification] = []

    func addNotification(_ notification: ReadingNotification) {
        notifications.insert(notification, at: 0) // mostre le più recenti in cima
    }
}


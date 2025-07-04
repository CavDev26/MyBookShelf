import SwiftUI

struct NotificationView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                .ignoresSafeArea()
            Text("Notifications - impostazioni")
        }
        .customNavigationTitle("Notifications")
    }
}

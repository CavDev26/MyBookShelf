import SwiftUI

struct PreferencesView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                .ignoresSafeArea()
            Text("preferences - impostazioni")
        }
        .customNavigationTitle("Preferences")
    }
}

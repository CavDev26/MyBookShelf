import SwiftUI

struct DiscoverView: View {

    var body: some View {
        NavigationStack {
            Form {
                Text("Discover")
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
            }
            .navigationTitle("DIscover")
        }
    }
}

#Preview {
    DiscoverView()
}

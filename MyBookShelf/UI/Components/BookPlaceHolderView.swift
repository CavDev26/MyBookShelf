import SwiftUI

struct BlankBookPlaceHolderView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedTab: Int

    var body: some View {
        Button {
            selectedTab = 1
        }label: {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colorScheme == .dark ? Color.terracottaDarkIcons : Color.peachColorIcons)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 4, y: 3)
                        .opacity(0.85)
                    GlossyOverlay()
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                }
                Text("Start a new adventure!")
                    .font(.system(size: 12, weight: .semibold))
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 3)
                    .padding(.bottom)
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedTab = 0
    HomeView(selectedTab: $selectedTab).modelContainer(PreviewData2.makeModelContainer())
}

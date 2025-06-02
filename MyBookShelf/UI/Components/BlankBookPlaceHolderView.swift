import SwiftUI

struct BlankBookPlaceHolderView : View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            NavigationLink(
                destination: PlaceHolderView()
            ) {
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.peachColorIcons)
                    
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.white)
                }
            }
        }
    }
}

#Preview {
    BlankBookPlaceHolderView()
}

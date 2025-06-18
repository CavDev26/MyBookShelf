import SwiftUI
import _SwiftData_SwiftUI

struct BookListItemGrid: View {
    var book: SavedBook
    var showStatus: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack(alignment: .topLeading){
                    Color.clear
                }
                ZStack(alignment: .bottomTrailing) {
                    if(!showStatus) {
                        Triangle()
                            .frame(width: 60, height: 60)
                            .foregroundColor(book.readingStatus.color)
                            .offset(x: 60)
                    }
                }
            }
            .background {
                    if let urlString = book.coverURL {
                        AsyncImageView(urlString: urlString)
                            
                    } else {
                        noBookCoverUrlView(width: geometry.size.width, height: geometry.size.height, bookTitle: book.title)
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: Color.black.opacity(showStatus ? 0 : 0.3), radius: 4, x: 5, y: 4)
        }
    }
}


struct BookListItemList: View {
    var book: SavedBook
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            BookRowDetailsView(book: book)
            Spacer()
        }
        .padding()
        .background (
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                Circle()
                    .fill(book.readingStatus.color)
                    .frame(width: 15, height: 15)
                    .padding()
            }
        )
        .padding(.vertical, 4)
    }
}



#Preview {
    @Previewable @State var selectedTab = 1
    return MyBooksView2(selectedTab: $selectedTab)
        .modelContainer(PreviewData2.makeModelContainer())
}

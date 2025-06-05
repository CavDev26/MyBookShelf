import SwiftUI
import _SwiftData_SwiftUI

struct BookListItemGrid: View {
    var book: SavedBook
    //var book: Book
    var showStatus: Bool
    var readingStatusColor: Color {
        switch book.readingStatus{
        case .reading:
            return .readingColor
        case .read:
            return .readColor
        case .unread:
            return .unreadColor
        }
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .topLeading){
                Color.clear
                Text(book.title)
                //Text(book.name)
                    .padding(-5)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .overlay(alignment: .bottomTrailing) {
                
                if let urlString = book.coverURL, let url = URL(string: urlString) {
                    AsyncImageView(
                        urlString: book.coverURL,
                        width: 60,
                        height: 90,
                        cornerRadius: 6
                    )
                }
                /*AsyncImage(
                    url: book.imageUrl,
                    content: { image in image.resizable() },
                    placeholder: { ProgressView().tint(.terracottaDarkIcons) }
                )*/
                if(!showStatus) {
                    Triangle()
                        .frame(width: 60, height: 60)
                        .foregroundColor(readingStatusColor)
                        .offset(x: 60, y: 60)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            if(showStatus) {
                progressViewBook(book: book)
            }
        }
        .shadow(color: Color.black.opacity(showStatus ? 0 : 0.3), radius: 4, x: 5, y: 4)
    }
}


struct BookListItemList: View {
    var book: SavedBook
    //var book: Book
    
    var readingStatusColor: Color {
        switch book.readingStatus {
        case .reading:
            return .readingColor
        case .read:
            return .readColor
        case .unread:
            return .unreadColor
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            
            if let urlString = book.coverURL, let url = URL(string: urlString) {
                AsyncImageView(
                    urlString: book.coverURL,
                    width: 60,
                    height: 90,
                    cornerRadius: 6
                )
            }
            
           /* AsyncImage(
                url: book.imageUrl,
                content: { image in image.resizable() },
                placeholder: { ProgressView().tint(.blue) }
            )
            .aspectRatio(1, contentMode: .fill)
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 12))*/
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                //Text(book.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(book.bookDescription ?? "No Description")
                //Text(book.tripDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text(book.publishedDate ?? "No date")
                //Text(book.date, format: Date.FormatStyle().day().month(.wide))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Circle()
                .fill(readingStatusColor)
                .frame(width: 12, height: 12)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 4, x: 2, y: 2)
        )
        .padding(.vertical, 4)
    }
}

struct progressViewBook: View {
    @State var size: CGSize = .zero
    var book: SavedBook
    //var book: Book

    var progress: CGFloat {
        
        guard book.pageCount! > 0 else { return 0 }
        //guard book.pages > 0 else { return 0 }
        return CGFloat(book.pagesRead) / CGFloat(book.pageCount!)
        //return CGFloat(book.pagesRead) / CGFloat(book.pages)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Custom progress bar
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                    .saveSize(in: $size)

                Capsule()
                    .fill(Color.terracottaDarkIcons)
                    .frame(width: progress * size.width, height: 8)
            }

            HStack(spacing: 8) {
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.trailing, 10)

                //Spacer()

                Button(action: {
                    //aggiorna in processo
                }) {
                    Text("Update")
                        .font(.caption)
                        .lineLimit(1)                // Blocca il testo su una sola riga
                        .minimumScaleFactor(0.5)     // Riduce il font fino al 50% se necessario
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.terracottaDarkIcons.opacity(0.15))
                        .foregroundColor(.terracottaDarkIcons)
                        .clipShape(Capsule())
                }
            }
        }
    }
}


#Preview {
    HomeView().modelContainer(PreviewData.makeModelContainer())
    //MyBooksView2().modelContainer(PreviewData.makeModelContainer())
}

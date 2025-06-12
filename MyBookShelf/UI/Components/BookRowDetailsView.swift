import SwiftUI

struct BookRowDetailsView<T: BookRepresentable>: View {
    var book: T
    var body: some View {
        if let urlString = book.coverURL {
            AsyncImageView(urlString: urlString)
                .frame(width: 60, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            noBookCoverUrlView(width: 60, height: 100, bookTitle: book.title)
        }
        VStack(alignment: .leading, spacing: 4) {
                        
            Text(book.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text(book.authors.joined(separator: ", "))
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Text(book.publisher == "Unknown" ? " " : book.publisher)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }    }
}


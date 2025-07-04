import SwiftUI

struct BookRowDetailsView<T: BookRepresentable>: View {
    var book: T

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let urlString = book.coverURL {
                    AsyncImageView(urlString: urlString)
                        .frame(width: 60, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    noBookCoverUrlView(width: 60, height: 100, bookTitle: book.title)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(.system(size: 16, weight: .semibold))
                    .fontDesign(.serif)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(book.authors.joined(separator: ", "))
                    .font(.system(size: 13))
                    .fontDesign(.serif)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(book.publisher == "Unknown" ? " " : book.publisher)
                    .font(.system(size: 13))
                    .fontDesign(.serif)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.65, alignment: .leading)
        }
        .padding(.bottom)
    }
}

import SwiftUI
import SwiftUICore

struct BookSearchDebugView: View {
    @StateObject private var viewModel = BookSearchViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Search by title, author, or ISBN", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    Button("Search") {
                        viewModel.searchBooks(query: searchText)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.trailing)
                }
                .padding(.top)

                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }

                List(viewModel.searchResults) { book in
                    
                    HStack{
                        if let urlString = book.coverURL, let url = URL(string: urlString) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.3)
                                    }
                                    .frame(width: 60, height: 90)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(book.title)
                                .font(.headline)

                            Text(book.authors.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if !book.publisher.isEmpty {
                                Text("Publisher: \(book.publisher)")
                                    .font(.caption)
                            }

                            if let date = book.publishedDate {
                                Text("Published: \(date)")
                                    .font(.caption2)
                            }

                            if let category = book.mainCategory {
                                Text("Category: \(category)")
                                    .font(.caption2)
                            }

                            if let rating = book.averageRating {
                                Text("Rating: \(String(format: "%.1f", rating)) ⭐️ (\(book.ratingsCount ?? 0) ratings)")
                                    .font(.caption2)
                            }

                            if let pageCount = book.pageCount {
                                Text("Pages: \(pageCount)")
                                    .font(.caption2)
                            }

                            if let desc = book.description {
                                Text(desc.prefix(150) + "…")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Book Search (Debug)")
        }
    }
}

#Preview {
    BookSearchDebugView()
}

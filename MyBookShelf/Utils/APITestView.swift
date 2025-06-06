import SwiftUI
import SwiftData

struct TestView: View {
    @Environment(\.modelContext) private var context
    @Query var savedBooks: [SavedBook]
    
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink(destination: BookSearchDebugView()) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.blue)
                        .overlay {
                            Text("test per api")
                                .foregroundColor(.white)
                        }
                        .frame(width: 100, height: 100)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Saved Books:")
                            .font(.headline)

                        ForEach(savedBooks) { book in
                            HStack {
                                if let urlString = book.coverURL, let url = URL(string: urlString) {
                                    AsyncImageView(
                                        urlString: book.coverURL//,
                                        //width: 60,
                                        //height: 90,
                                        //cornerRadius: 6
                                    )
                                }

                                VStack(alignment: .leading) {
                                    Text(book.title)
                                        .font(.headline)
                                    Text(book.authors.joined(separator: ", "))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}


struct BookSearchDebugView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = BookSearchViewModel()
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss

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
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            if let urlString = book.coverURL, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(width: 60, height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(book.title)
                                    .font(.headline)

                                Text(book.authors.joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                if let publisher = Optional(book.publisher) {
                                    Text("Publisher: \(publisher)")
                                        .font(.caption)
                                }

                                if let date = book.publishedDate {
                                    Text("Published: \(date)")
                                        .font(.caption2)
                                }

                                if let pageCount = book.pageCount {
                                    Text("Pages: \(pageCount)")
                                        .font(.caption2)
                                }

                                Button("Add to My Library") {
                                    let saved = SavedBook(from: book)
                                    context.insert(saved)

                                    DispatchQueue.main.async {
                                        do {
                                            try context.save()
                                            print("✅ Saved: \(saved.title)")
                                            dismiss()
                                        } catch {
                                            print("❌ Save error: \(error)")
                                        }
                                    }
                                }
                                .font(.caption)
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Book Search (Debug)")
        }
    }
}



#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SavedBook.self, configurations: config)

    // Dati di esempio
    /*let example = SavedBook(
        id: "preview-id",
        title: "The Swift Adventure",
        authors: ["Jane Appleseed"],
        publisher: "Cupertino Books",
        coverURL: "https://via.placeholder.com/150",
        pageCount: 320,
        bookDescription: "Un viaggio attraverso Swift e SwiftUI.",
        publishedDate: "2024-01-01",
        industryIdentifiers: [],
        categories: ["Programming"],
        mainCategory: "Development",
        averageRating: 4.5,
        ratingsCount: 42
    )*/
    
    //container.mainContext.insert(example)

    return TestView()
        .modelContainer(container)
}

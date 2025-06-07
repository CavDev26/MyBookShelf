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
    @StateObject private var viewModel = CombinedGenreSearchViewModel()
    //@StateObject private var viewModel = BookSearchViewModel()
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
                let books = viewModel.searchResults
                ScrollView {
                    SearchResultList(books: books)
                    if !viewModel.isLoading {
                        Button {
                            viewModel.loadMoreSearchResults()
                        } label: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.terracotta)
                                .overlay{
                                    Text("Load More")
                                        .foregroundColor(.white)
                                }
                                .frame(width: 150, height: 50, alignment: .center)
                                .shadow(radius: 8)
                        }
                        .padding()
                    } else {
                        ProgressView()
                            .padding()
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
    
    return TestView()
        .modelContainer(container)
}

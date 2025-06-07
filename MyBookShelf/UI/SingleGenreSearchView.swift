import SwiftUICore
import SwiftData
import SwiftUI

struct SingleSearchView: View {
    @StateObject private var viewModel = CombinedGenreSearchViewModel()
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    let genre: BookGenre

    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    SearchResultList(books: viewModel.searchResults)

                    if !viewModel.isLoading {
                        
                        Button {
                            viewModel.loadMore()
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
                .padding(.top)
            }
        }
        .navigationTitle("\(genre.rawValue.capitalized) Books")
        .onAppear {
            if viewModel.searchResults.isEmpty {
                viewModel.searchByGenreSmart(genre: genre.rawValue)
            }
        }
    }
}
#Preview {
    AddBooksView()
}


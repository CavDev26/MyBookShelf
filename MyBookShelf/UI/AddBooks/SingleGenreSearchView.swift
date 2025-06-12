import SwiftUICore
import SwiftData
import SwiftUI

struct SingleSearchView: View {
    @StateObject private var viewModel = CombinedGenreSearchViewModel()
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    let genre: BookGenre
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                .ignoresSafeArea()
            
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack {
                        if viewModel.searchResults.isEmpty {
                            SearchResultListPreview()

                        } else {
                            SearchResultList(viewModel: viewModel, books: viewModel.searchResults)
                            if viewModel.loadedCount < viewModel.allTitles.count {
                                LoadMoreButtonView(viewModel: viewModel, scrollProxy: scrollProxy, topPicks: false)
                            }
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .customNavigationTitle("\(genre.rawValue.capitalized) Books")
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


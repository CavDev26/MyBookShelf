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
                        SearchResultList(books: viewModel.searchResults)
                        
                        if !viewModel.isLoading {
                            Button {
                                let lastID = viewModel.searchResults.last?.id ?? UUID().uuidString
                                let oldCount = viewModel.searchResults.count
                                viewModel.loadMore {
                                    let didLoadNew = viewModel.searchResults.count > oldCount
                                    if didLoadNew {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                            withAnimation {
                                                scrollProxy.scrollTo(lastID, anchor: .top)
                                            }
                                        }
                                    }
                                }
                            } label: {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.terracotta)
                                    .overlay {
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


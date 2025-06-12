import SwiftUICore
import SwiftUI


struct TopPicksVIew: View {
    @ObservedObject var viewModel: CombinedGenreSearchViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                .ignoresSafeArea()
            ScrollViewReader { scrollProxy in
                
                ScrollView {
                    VStack {
                        if viewModel.searchResultsBS.isEmpty {
                            SearchResultListPreview()
                        } else {
                            SearchResultList(viewModel: viewModel, books: viewModel.searchResultsBS)
                            if viewModel.loadedCount < viewModel.allTitles.count {
                                LoadMoreButtonView(viewModel: viewModel, scrollProxy: scrollProxy, topPicks: true)
                            }
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .customNavigationTitle("Best Sellers")
    }
}
#Preview {
    AddBooksView()
}

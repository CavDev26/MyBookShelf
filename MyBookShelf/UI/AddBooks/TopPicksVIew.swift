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
                        }
                        SearchResultList(books: viewModel.searchResultsBS)
                        if !viewModel.isLoading {
                            Button {
                                let lastID = viewModel.searchResultsBS.last?.id ?? UUID().uuidString
                                let oldCount = viewModel.searchResultsBS.count
                                viewModel.loadMore(topPicks: true) {
                                    let didLoadNew = viewModel.searchResultsBS.count > oldCount
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
                            
                            //ProgressView()
                            //.padding()
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

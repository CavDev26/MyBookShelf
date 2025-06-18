import SwiftUICore
import SwiftData
import SwiftUI

struct AuthorResultsVIew: View {
    @StateObject private var viewModel = CombinedGenreSearchViewModel()
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    var author: String
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                .ignoresSafeArea()
            
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack {
                        if viewModel.searchResultsAuthor.isEmpty {
                            SearchResultListPreview()
                            
                        } else {
                            SearchResultList(viewModel: viewModel, books: viewModel.searchResultsAuthor)
                            if !viewModel.isLoading {
                                Button {
                                    let lastID = viewModel.searchResultsAuthor.last?.id ?? UUID().uuidString
                                    let oldCount = viewModel.searchResultsAuthor.count
                                    viewModel.searchBooksByAuthor(author, reset: false) { _ in
                                        let didLoadNew = viewModel.searchResultsAuthor.count > oldCount
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
                                }
                                .frame(width: 150, height: 50, alignment: .center)
                                .shadow(radius: 8)
                                .padding()
                                .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.clear)
                                    .overlay(ProgressView())
                                    .frame(width: 150, height: 50, alignment: .center)
                                    .shadow(radius: 8)
                                    .padding()
                                    .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
                            }
                            
                            
                            
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .customNavigationTitle("\(author)")
        .onAppear {
            if viewModel.searchResultsAuthor.isEmpty {
                viewModel.searchBooksByAuthor(author)
            }
        }
    }
}
#Preview {
    AuthorResultsVIew(author: "Tolkien")
}


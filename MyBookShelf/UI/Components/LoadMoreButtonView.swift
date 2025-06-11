//
//  LoadMoreButtonView.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 11/06/25.
//

import SwiftUI

struct LoadMoreButtonView: View {
    
    @ObservedObject var viewModel: CombinedGenreSearchViewModel
    var scrollProxy: ScrollViewProxy
    var topPicks: Bool
    
    var body: some View {
        Group {
            if !viewModel.isLoading {
                Button {
                    if(topPicks) {
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
                    } else {
                        let lastID = viewModel.searchResults.last?.id ?? UUID().uuidString
                        let oldCount = viewModel.searchResults.count
                        viewModel.loadMore(topPicks: false) {
                            let didLoadNew = viewModel.searchResults.count > oldCount
                            if didLoadNew {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    withAnimation {
                                        scrollProxy.scrollTo(lastID, anchor: .top)
                                    }
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
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.clear)
                    .overlay(ProgressView())
            }
        }
        .frame(width: 150, height: 50, alignment: .center)
        .shadow(radius: 8)
        .padding()
        .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)    }
}

#Preview {
    //LoadMoreButtonView()
}

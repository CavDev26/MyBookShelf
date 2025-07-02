//
//  WatchHomeView.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 02/07/25.
//
import SwiftUI
import SwiftUICore


struct WatchHomeView: View {
    var body: some View {
        VStack {
            HStack{
                Image("icon").resizable().frame(width: 30, height: 30)
                Text("MyBookShelf")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
            /*Text("📚 MyBookShelf")
                .font(.headline)
                .padding(.top)*/

            NavigationLink(destination: BookSelectionView()) {
                Text("Start a reading session")
                    .padding()
            }
            .padding(.bottom, 20)
        }
    }
}


import SwiftUI

struct BookSelectionView: View {
    @ObservedObject var manager = WatchSessionManager.shared

    var body: some View {
        List(manager.readingBooks) { book in
            NavigationLink(destination: ReadingSessionView(book: book)) {
                HStack {
                    if let urlString = book.coverData {
                        AsyncImageView(urlString: urlString)
                            .frame(width: 40, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    } else {
                        noBookCoverUrlView(width: 40, height: 60, bookTitle: book.title)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }

                    VStack(alignment: .leading) {
                        Text(book.title)
                            .font(.footnote)
                            .lineLimit(1)
                        Text(book.author)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Choose a book")
    }
}

import SwiftUICore
import SwiftUI

struct BookListViewGrid: View {
    var books: [Book]
    @State var showAddBookSheet = false

    var body: some View {
        let columnCount: Int = 3
        let gridSpacing: CGFloat = -20.0

        ScrollView(.vertical) {
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: gridSpacing), count: columnCount), spacing: gridSpacing) {
                ForEach(books) { book in
                    NavigationLink(
                        destination: BookDetailsView(book: book)
                    ) {
                        BookListItemGrid(book: book, showStatus: false).aspectRatio(2/3, contentMode: .fit).padding(.horizontal).padding(.vertical, 8)
                    }
                }
            }
        }
        .overlay(alignment: .center) {
            if books.isEmpty {
                ContentUnavailableView(
                    label: { Label("No books", systemImage: "map") },
                    description: {
                        Text("Add a new book to see your list.")
                    },
                    actions: {
                        Button(action: {
                            showAddBookSheet = true
                        }) {
                            Text("Add book")
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showAddBookSheet) {
            AddBookSheet()
        }
    }
}

struct BookListViewList: View {
    var books: [Book]
    @State var showAddBookSheet = false
    var body: some View {
        let columnCount: Int = 1
        let gridSpacing: CGFloat = -20.0

        ScrollView(.vertical) {
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: gridSpacing), count: columnCount), spacing: gridSpacing) {
                ForEach(books) { book in
                    NavigationLink(
                        destination: BookDetailsView(book: book)
                    ) {
                        BookListItemList(book: book).aspectRatio(contentMode: .fit).padding(.horizontal).padding(.vertical, 6)
                    }
                }
            }
        }
        .overlay(alignment: .center) {
            if books.isEmpty {
                ContentUnavailableView(
                    label: { Label("No books", systemImage: "map") },
                    description: {
                        Text("Add a new book to see your list.")
                    },
                    actions: {
                        Button(action: {
                            showAddBookSheet = true
                        }) {
                            Text("Add book")
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showAddBookSheet) {
            AddBookSheet()
        }
    }
}

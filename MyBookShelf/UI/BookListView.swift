//
//  TripListView.swift
//  TravelDiary
//
//  Created by Gianni Tumedei on 07/05/25.
//

import SwiftData
import SwiftUI

struct BookListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Book.date, order: .reverse) var books: [Book]

    @State var showAddBookSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(books) { book in
                    NavigationLink(
                        destination: BookDetailsView(book: book)
                    ) {
                        BookListItem(book: book)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(books[index])
                    }
                }
            }
            .navigationTitle("MyBookShelf")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !books.isEmpty {
                    ToolbarItem {
                        Button(action: {
                            showAddBookSheet = true
                        }) {
                            Label("Add books", systemImage: "plus")
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
}

#Preview {
    BookListView().modelContainer(PreviewData.makeModelContainer())
}

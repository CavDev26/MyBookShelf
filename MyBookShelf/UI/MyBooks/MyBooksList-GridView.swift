import SwiftUICore
import SwiftUI

struct BookListViewGrid: View {
    var books: [SavedBook]
    @Environment(\.colorScheme) var colorScheme
    //var books: [Book]
    @Binding var selectedTab: Int
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
                    label: { Label("No books", systemImage: "books.vertical.fill") },
                    actions: {
                        
                        Button {
                            selectedTab = 2
                        } label: {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                                .frame(width: 100, height: 50)
                                .overlay {
                                    Text("Add a new book!")
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                }
                        }
                        .padding()
                        
                        
                        /*NavigationLink(
                            destination: AddBooksView()
                        ) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                                .frame(width: 100, height: 50)
                                .overlay {
                                    Text("Add a new book!")
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                }
                        }
                        //.navigationBarBackButtonHidden(true)
                        .padding()*/
                        /*Button(action: {
                            showAddBookSheet = true
                        }) {
                            Text("Add book")
                        }*/
                    }
                )
            }
        }
        /*.sheet(isPresented: $showAddBookSheet) {
            AddBookSheet()
        }*/
    }
}

struct BookListViewList: View {
    var books: [SavedBook]
    //var books: [Book]
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

#Preview {
    @Previewable @State var selectedTab = 1
    return MyBooksView2(selectedTab: $selectedTab)
        .modelContainer(PreviewData2.makeModelContainer())
}

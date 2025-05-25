import SwiftData
import SwiftUI

struct BookListView: View {
    
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Book.date, order: .reverse) var books: [Book]

    @State var isView1 = false


    var body: some View {
        ZStack{
            Color.blue.ignoresSafeArea()
            
            NavigationStack {
                VStack{
                    HStack (){
                        Image("MyIcon").resizable().frame(width: 50, height: 50).padding(.leading)
                        Text("MyBookShelf").frame(maxWidth: .infinity, alignment: .leading).font(.custom("Baskerville-SemiBoldItalic", size: 20))
                        Button(action: {
                            isView1 = !isView1
                        }) {
                            Image(systemName: isView1 ? "rectangle.grid.3x2.fill" : "rectangle.grid.1x2.fill")
                                .contentTransition(.symbolEffect(.replace))
                        }.padding(.horizontal)
                    }
                    
                    switch isView1{
                    case true:
                        BookListViewGrid(books: books)
                        
                    case false:
                        BookListViewList(books : books)
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

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
                        BookListItem(book: book).aspectRatio(2/3, contentMode: .fit).padding(.horizontal).padding(.vertical, 8)
                    }
                }
            }
        }
        .background(Color.clear)
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
        let gridSpacing: CGFloat = 0.0

        ScrollView(.vertical) {
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: gridSpacing), count: columnCount), spacing: gridSpacing) {
                ForEach(books) { book in
                    NavigationLink(
                        destination: BookDetailsView(book: book)
                    ) {
                        BookListItem2(book: book).aspectRatio(3/1, contentMode: .fit).padding(.horizontal).padding(.vertical, 6)
                    }
                }
            }
        }
        .background(Color.clear)
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
    BookListView().modelContainer(PreviewData.makeModelContainer())
}

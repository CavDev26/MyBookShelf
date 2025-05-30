import SwiftData
import SwiftUI

struct MyBooksView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var vm = ViewModel()
    @Environment(\.modelContext) private var modelContext
    @State var isViewGrid: Bool = true
    @State var searching: Bool = false

    @Query(sort: \Book.name, order: .forward) var books: [Book]
    


    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(colorScheme == .dark ? vm.backgroundColorDark : vm.backgroundColorLight)
                    .ignoresSafeArea()
                    .opacity(colorScheme == .dark ? 1 : 0.5)
                
                VStack{
                    ZStack(alignment: .top) {
                        HStack (){
                            Image("MyIcon").resizable().frame(width: 50, height:50).padding(.leading)
                                .opacity(searching ? 0 : 1)
                            Text("MyBookShelf").frame(maxWidth: .infinity, alignment:.leading).font(.custom("Baskerville-SemiBoldItalic", size: 20))
                                .opacity(searching ? 0 : 1)
                            Button(action: {
                                withAnimation(.linear(duration: 0.1)){
                                    searching.toggle()
                                }
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                            .opacity(searching ? 0 : 1)
                            
                            Button(action: {
                                withAnimation(.snappy(duration: 0.2)) {
                                    isViewGrid.toggle()
                                }
                            }) {
                                Image(systemName: isViewGrid ? "rectangle.grid.1x2.fill" : "rectangle.grid.3x2.fill")
                                    .contentTransition(.symbolEffect(.replace))
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                            .padding(.horizontal)
                            .opacity(searching ? 0 : 1)
                                
                             
                        }
                        .frame(width: .infinity, height: 50)
                        .padding(.bottom)
                        .background {
                            Color(colorScheme == .dark ? vm.backgroundColorDark2 : vm.backgroundColorLight)
                                .ignoresSafeArea()
                        }
                        HStack {
                            ScanSearchBarView(scan: false)
                                .padding(.leading)
                                .opacity(searching ? 1 : 0)
                            Button(action: {
                                withAnimation(.linear(duration: 0.1)){
                                    searching.toggle()
                                }
                            }) {
                                Text("Cancel")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                    .padding(.trailing)
                            }
                            .opacity(searching ? 1 : 0)
                        }
                    }
                    
                    
                    switch isViewGrid{
                    case true:
                        BookListViewGrid(books: books)
                        
                    case false:
                        BookListViewList(books : books)
                    }
                }
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


#Preview {
    MyBooksView().modelContainer(PreviewData.makeModelContainer())
}

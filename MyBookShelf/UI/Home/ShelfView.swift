import SwiftUICore
import _SwiftData_SwiftUI
import SwiftUI
import MapKit

struct ShelfView: View {
    var shelf: Shelf
    @Environment(\.colorScheme) var colorScheme
    @State private var showAllBooks = false
    @State var showAddBookShelfSheet: Bool = false
    @ObservedObject var viewModel: CombinedGenreSearchViewModel

    
    private var books: [SavedBook] {
        shelf.books
    }
    
    private var mapRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: shelf.latitude ?? 0,
                longitude: shelf.longitude ?? 0
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // circa 10km
        )
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Sezione libri
                        HStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.terracotta)
                                .frame(width: 4, height: 20)
                            
                            Text("Books in this shelf")
                                .font(.system(size: 20, weight: .semibold, design: .serif))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    if !books.isEmpty {

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                            if showAllBooks {
                                ForEach(books) { book in
                                    NavigationLink(
                                        destination: BookDetailsView(book: book, viewModel: viewModel)
                                    ) {
                                        BookListItemGrid(book: book, showStatus: false)
                                            .aspectRatio(2/3, contentMode: .fill)
                                            .padding(4)
                                    }
                                }
                            } else {
                                ForEach(books.prefix(6), id: \.self) { book in
                                    NavigationLink(
                                        destination: BookDetailsView(book: book, viewModel: viewModel)
                                    ) {
                                        BookListItemGrid(book: book, showStatus: false)
                                            .aspectRatio(2/3, contentMode: .fill)
                                            .padding(4)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if books.count > 6 {
                            Button(action: { showAllBooks.toggle() }) {
                                Text(showAllBooks ? "Show Less" : "Show More")
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else { //no books
                        Text("No books.\nYou can add them by tapping the plus button in the top right corner.")
                    }
                    
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.terracotta)
                            .frame(width: 4, height: 20)
                        
                        Text("Description")
                            .font(.system(size: 20, weight: .semibold, design: .serif))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    VStack {
                        Text("desc di prova ahahaha")
                    }
                    
                    // Mappa
                    if let lat = shelf.latitude, let lon = shelf.longitude {
                        Map(coordinateRegion: .constant(mapRegion), annotationItems: [shelf]) { _ in
                            MapMarker(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), tint: .red)
                        }
                        .frame(height: 250)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
                .padding(.top)
            }
        }
        .customNavigationTitle(shelf.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddBookShelfSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddBookShelfSheet) {
            AddBooksToShelfSheet(shelf: shelf)
        }
    }
}




struct AddBooksToShelfSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \SavedBook.title) var allBooks: [SavedBook]
    
    var shelf: Shelf

    var body: some View {
        NavigationStack {
            List {
                ForEach(allBooks) { book in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(book.title)
                                .font(.headline)
                            if let author = book.authors.first {
                                Text(author)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Button {
                            if shelf.books.contains(book) {
                                // Rimuove il libro
                                shelf.books.removeAll { $0.id == book.id }
                            } else {
                                // Aggiunge il libro
                                shelf.books.append(book)
                            }
                        } label: {
                            Image(systemName: shelf.books.contains(book) ? "checkmark.circle.fill" : "plus.circle")
                                .foregroundColor(shelf.books.contains(book) ? .green : .blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Add Books to this shelf")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

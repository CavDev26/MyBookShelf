import SwiftUI
import _SwiftData_SwiftUI
import MapKit
import UIKit
import CoreImage

struct BookDetailsView: View {
    @State var book: BookRepresentable
    @State private var savedBook: SavedBook? = nil
    
    @State private var dominantColor: Color = .gray.opacity(0.2)
    @State private var titleOffset: CGFloat = .infinity
    @State private var showNavTitle = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    @ObservedObject var viewModel: CombinedGenreSearchViewModel
    
    @State private var isExpanded = false
    @State private var showEditProgressSheet: Bool = false
    
    
    @State private var isSaved: Bool = false
    @State private var showRemoveAlert = false
    @State private var bookToRemove: SavedBook? = nil
    @Query var savedBooks: [SavedBook]
    var savedBookIDs: Set<String> {
        Set(savedBooks.map { $0.id })
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                .ignoresSafeArea()
            
            GeometryReader { outerGeo in
                ScrollView {
                    VStack(spacing: 0) {
                        detailCoverView(book: book)
                        detailTAView(titleOffset: $titleOffset, showNavTitle: $showNavTitle, book: book)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 15)
                                        
                    VStack(alignment: .center, spacing: 8) {
                        if let savedBook = book as? SavedBook {
                            dividerRectangle()

                            HStack {
                                readingStatusMenuVIew(book: savedBook)
                                
                                RatingView(book: savedBook, color: dominantColor, rating: Double(savedBook.rating ?? Int(0.0)))
                                    .padding(.horizontal)
                            }
                            .padding(.bottom)
                            
                            
                            detailsProgressView(showEditProgressSheet: $showEditProgressSheet, book: savedBook)
                            
                            detailsBookNotesView(localNotes: savedBook.userNotes, book: savedBook, isExpanded: $isExpanded)
                        } else {
                            HStack(spacing: 8) {
                                Button {
                                    if !savedBookIDs.contains(book.id) {
                                        if let bookAPI = book as? BookAPI {
                                            viewModel.saveBook(bookAPI, context: context)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                if let saved = savedBooks.first(where: { $0.id == bookAPI.id }) {
                                                    withAnimation(.easeInOut(duration: 0.3)) {
                                                        
                                                        self.savedBook = saved
                                                        self.book = saved
                                                        self.isSaved = true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    addBookButtonView(color: dominantColor, isSaved: isSaved)
                                }
                            }
                        }
                        dividerRectangle()
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    ExpandableDescriptionView(text: book.descriptionText ?? "No description available")
                        .padding(.leading)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                    detailsGenreView(book: book, viewModel: viewModel)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                        .padding(.bottom)

                    if let savedBook = book as? SavedBook {
                        Button {
                            bookToRemove = savedBook
                            showRemoveAlert.toggle()
                        } label: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(dominantColor)
                                //.fill(Color.terracottaDarkIcons)
                                .frame(width: 150, height: 40)
                                .overlay{
                                    Text("Remove book")
                                        .minimumScaleFactor(0.8)
                                        .foregroundColor(.white)
                                        .padding()
                                }
                        }
                        .padding(.bottom)
                    }
                    
                    VStack(alignment: .center, spacing: 8) {
                        dividerRectangle()
                    }
                        relatedBooksView(book: book, viewModel: viewModel, vmsearchResults: $viewModel.searchResultsRelated, isAuthor: false)
                        relatedBooksView(book: book, viewModel: viewModel, vmsearchResults: $viewModel.searchResultsAuthor, isAuthor: true)
                }
                .frame(maxWidth: .infinity)
            }
            .onAppear {
                if let coverURL = URL(string: book.coverURL ?? ""){
                    fetchDominantColor(from: coverURL) { color in
                        dominantColor = color
                    }
                } else {
                    dominantColor = Color.terracotta
                }
                //  Controllo se il libro è già salvato
                if let alreadySaved = savedBooks.first(where: { $0.id == book.id }) {
                    self.book = alreadySaved
                    self.savedBook = alreadySaved
                    self.isSaved = true
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(book.title)
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .opacity(showNavTitle ? 1 : 0)
                        .animation(.easeInOut(duration: 0.25), value: showNavTitle)
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if let savedBook = book as? SavedBook {
                        Button {
                            savedBook.favourite = !savedBook.favourite
                            try? context.save()
                        } label: {
                            Image(systemName: savedBook.favourite ? "bookmark.fill" : "bookmark")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .toolbarBackground(dominantColor.opacity(1), for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showEditProgressSheet) {
                if let savedBook = book as? SavedBook {
                    EditProgressSheetView(book: savedBook)
                        .presentationDetents([.fraction(0.25), .medium])
                        .presentationDragIndicator(.visible)
                }
            }
            .alert("Remove from Library?", isPresented: $showRemoveAlert, presenting: bookToRemove) { book in
                Button("Remove", role: .destructive) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        context.delete(book)
                        do {
                            try context.save()
                            print("🗑️ Removed: \(book.title)")
                            
                            // Torna alla rappresentazione BookAPI
                            self.book = BookAPI(from: book)
                            self.savedBook = nil
                            self.isSaved = false
                        } catch {
                            print("❌ Delete error: \(error)")
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: { book in
                Text("Are you sure you want to remove \"\(book.title)\" from your library?")
            }
        }
    }
}


struct dividerRectangle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.gray.opacity(0.5))
            .frame(width: 150, height: 3, alignment: .center)
            .padding(.bottom, 20)
    }
}

func fetchDominantColor(from url: URL?, completion: @escaping (Color) -> Void) {
    guard let url = url else { return }
    URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let data = data,
              let uiImage = UIImage(data: data) else { return }
        
        let color = uiImage.suitableBackgroundColor()
        
        DispatchQueue.main.async {
            completion(color)
        }
    }.resume()
}


struct detailsGenreView : View {
    var book: BookRepresentable
    @State private var genres: [BookGenre]? = nil
    @ObservedObject var viewModel: CombinedGenreSearchViewModel
    
    var body: some View {
        if let savedBook = book as? SavedBook {
            if let genres = savedBook.genres {
                Text("Genres: \(genres.map { $0.rawValue }.joined(separator: ", "))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
            } else {
                Text("Genres: None")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        } else if book is BookAPI {
            if let genres = genres {
                if genres == [] || genres == [.unknown] {
                    Text("Genres: None")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                } else {
                    Text("Genres: \(genres.map { $0.rawValue }.joined(separator: ", "))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            } else {
                ProgressView("Fetching genres...")
                    .onAppear {
                        viewModel.fetchGenreFromOpenLibrary(title: book.title) { fetched in
                            genres = fetched
                        }
                    }
            }
        }
    }
}

struct detailTAView: View {
    @Binding var titleOffset: CGFloat
    @Binding var showNavTitle: Bool
    var book: BookRepresentable
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(book.title)
                .font(.system(size: 30, weight: .semibold, design: .serif))
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                titleOffset = geo.frame(in: .global).minY
                            }
                            .onChange(of: geo.frame(in: .global).minY) { newVal in
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showNavTitle = newVal < 100
                                }
                            }
                    }
                )
            HStack {
                ForEach (book.authors, id: \.self) { a in
                    NavigationLink (destination: PlaceHolderView()) {
                        Text(a)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}
struct detailCoverView: View {
    var book: BookRepresentable
    var body: some View {
        ZStack {
            if let urlString = book.coverURL {
                AsyncImageView(urlString: urlString)
                    .frame(width: 180, height: 280)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.5), radius: 4, x: 4, y: 4)
                    .padding()
            } else {
                noBookCoverUrlView(width: 180, height: 280, bookTitle: book.title)
                    .cornerRadius(8)
                    //.shadow(color: Color.black.opacity(0.5), radius: 4, x: 4, y: 4)
                    .padding()
            }
        }
    }
}

struct RatingView : View {
    var book: SavedBook
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) var colorScheme
    
    var color: Color
    var maximumRating = 5
    var starSize: CGFloat = 24
    var allowsHalfStars = true
    @State var rating: Double
    
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maximumRating, id: \.self) { index in
                Image(systemName: starType(for: index))
                    .resizable()
                    .scaledToFit()
                    .frame(width: starSize, height: starSize)
                    .foregroundColor(Color.terracotta)
                    .onTapGesture {
                        withAnimation {
                            if allowsHalfStars && rating == Double(index) {
                                rating = Double(index) - 0.5
                            } else {
                                rating = Double(index)
                            }
                        }
                        book.rating = Int(rating)
                        try? context.save()
                    }
            }
        }
    }
    
    private func starType(for index: Int) -> String {
        if rating >= Double(index) {
            return "star.fill"
        } else if rating >= Double(index) - 0.5 {
            return "star.lefthalf.fill"
        } else {
            return "star"
        }
    }
    
}

struct readingStatusMenuVIew: View {
    @Environment(\.modelContext) private var context
    var book: SavedBook
    
    var body: some View {
        
            Menu {
                ForEach(ReadingStatus.assignableCases, id: \.self) { status in
                    Button {
                        book.readingStatus = status
                        try? context.save()
                    } label: {
                        Label(status.rawValue.capitalized, systemImage: status.iconName)
                    }
                }
            } label: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(book.readingStatus.color)
                    .frame(height: 50)
                    .overlay{
                        HStack {
                            Text(book.readingStatus.rawValue.capitalized)
                                .foregroundColor(.secondary)
                        }
                    }
                    .animation(.easeInOut(duration: 0.25), value: book.readingStatus)
            }
            .menuOrder(.fixed)
            
            
            
            /*Circle()
             .fill(book.readingStatus.color)
             .frame(width: 20, height: 20)
             .overlay(
             Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1)
             )
             .animation(.easeInOut(duration: 0.25), value: book.readingStatus)
        }*/
    }
}

struct detailsProgressView: View {
    @Binding var showEditProgressSheet: Bool
    @State var size: CGSize = .zero
    var book: SavedBook
    var progress: CGFloat {
        
        guard book.pageCount! > 0 else { return 0 }
        return CGFloat(book.pagesRead) / CGFloat(book.pageCount!)
    }
    
    var body: some View {
        if book.readingStatus == .reading || book.readingStatus == .read {
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .saveSize(in: $size)
                    
                    Capsule()
                        .fill(Color.terracottaDarkIcons)
                        .frame(width: progress * size.width, height: 8)
                }.padding(.top)
                
                HStack(spacing: 8) {
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    //.padding(.trailing, 10)
                    
                    
                    Button(action: {
                        showEditProgressSheet.toggle()
                    }) {
                        Text("Update")
                            .font(.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        //.padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.terracottaDarkIcons.opacity(0.15))
                            .foregroundColor(.terracottaDarkIcons)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
}

struct detailsBookNotesView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) var colorScheme
    @State var localNotes: String
    var book: SavedBook
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Notes")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                
                VStack(alignment: .leading, spacing: 8) {
                    ZStack(alignment: .topLeading) {
                        Text(localNotes.isEmpty ? "Tap to add notes..." : localNotes)
                            .foregroundColor(localNotes.isEmpty ? .secondary : .primary)
                            .opacity(isExpanded ? 0 : 1)
                            .animation(.easeInOut(duration: 0.2), value: isExpanded)
                        
                        TextEditor(text: $localNotes)
                            .opacity(isExpanded ? 1 : 0)
                            .disabled(!isExpanded)
                            .scrollContentBackground(.hidden)
                            .animation(.easeInOut(duration: 0.2), value: isExpanded)
                    }
                    .frame(maxHeight: isExpanded ? nil : 140)
                    
                    if isExpanded {
                        HStack {
                            Spacer()
                            Button("Save") {
                                book.userNotes = localNotes
                                try? context.save()
                                withAnimation {
                                    isExpanded = false
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.terracotta)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            .animation(.easeInOut(duration: 0.3), value: isExpanded)
        }
        .onTapGesture {
            if !isExpanded {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded = true
                }
            }
        }
    }
}

struct relatedBooksView: View {
    var book: BookRepresentable
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: CombinedGenreSearchViewModel
    @Binding var vmsearchResults: [BookAPI]
    var isAuthor: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(isAuthor ? "Books from this author" : "Related Books")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }.padding(.top)
                .padding(.horizontal)
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if vmsearchResults.isEmpty {
                        ForEach(0..<10, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 150)
                                .redacted(reason: .placeholder)
                                .shimmering()
                        }
                    } else {
                        ForEach(vmsearchResults.prefix(10)) { book in
                            NavigationLink {
                                BookDetailsView(book: book, viewModel: viewModel)
                            } label: {
                                if let urlString = book.coverURL {
                                    AsyncImageView(urlString: urlString)
                                        .frame(width: 100, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    noBookCoverUrlView(width: 100, height: 150, bookTitle: book.title)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.top)
            
        }
        .padding(.top)
        .onAppear {
            vmsearchResults = []
            if isAuthor {
                viewModel.fetchBooksFromAuthor(title: book.title, authors: book.authors)
            } else {
                viewModel.fetchRelatedBooks(title: book.title, authors: book.authors)
            }
        }
    }
}
struct ExpandableDescriptionView: View {
    let text: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Description")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(text)
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .foregroundColor(.secondary)
                .lineLimit(isExpanded ? nil : 8)
                .animation(.easeInOut, value: isExpanded)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if text.count > 200 {
                Button(isExpanded ? "Less" : "More") {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
    }
}




struct EditProgressSheetView: View {
    var book: SavedBook
    var body: some View {
        Text("Edit progress")
    }
}












struct MapArea: View {
    var location: CLLocationCoordinate2D
    
    var body: some View {
        let region = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
        let cameraPosition = MapCameraPosition.region(region)
        
        Map(position: .constant(cameraPosition))
            .allowsHitTesting(false)
    }
}

struct RoundImage: View {
    var url: URL?
    
    var body: some View {
        ZStack {
            Rectangle().fill(.blue.opacity(0.2))
            AsyncImage(
                url: url,
                content: { image in image.resizable() },
                placeholder: { ProgressView().tint(.blue) }
            )
        }
        .background(.background)
        .clipShape(Circle())
        .overlay(Circle().stroke(.background, lineWidth: 6))
    }
}

#Preview {
    @Previewable @State var selectedTab = 1
    return MyBooksView2(selectedTab: $selectedTab)
        .modelContainer(PreviewData2.makeModelContainer())
}


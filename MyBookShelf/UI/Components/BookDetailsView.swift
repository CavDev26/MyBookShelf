import SwiftUI
import MapKit
import UIKit
import CoreImage

struct BookDetailsView<T: BookRepresentable>: View {
    var book: T
    @State private var dominantColor: Color = .gray.opacity(0.2)
    @State private var titleOffset: CGFloat = .infinity
    @State private var showNavTitle = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    @ObservedObject var viewModel: CombinedGenreSearchViewModel
    
    
    @State private var showEditProgressSheet: Bool = false

    
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                .ignoresSafeArea()
            
            GeometryReader { outerGeo in
                ScrollView {
                    VStack(spacing: 0) {
                        detailCoverView(book: book)
                        detailTAView(titleOffset: $titleOffset, showNavTitle: $showNavTitle, book: book)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        
                        if let savedBook = book as? SavedBook {
                            RatingView(book: savedBook, color: dominantColor, rating: Double(savedBook.rating ?? Int(0.0)))
                                .padding(.horizontal)
                        }
                        
                        if let savedBook = book as? SavedBook {
                            readingStatusMenuVIew(book: savedBook)
                        }
                        
                        detailsGenreView(book: book, viewModel: viewModel)
                        
                        
                        if let savedBook = book as? SavedBook {
                            detailsProgressView(showEditProgressSheet: $showEditProgressSheet, book: savedBook)
                        }
                        
                        
                        
                        
                        Text("Description")
                            .font(.system(size: 25, weight: .semibold, design: .serif))
                            .bold()
                        Text(book.descriptionText ?? "No description")
                            .font(.system(size: 20, weight: .light, design: .serif))
                            .padding(.horizontal, 8)
                        
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
            }
            .onAppear {
                let coverURL = URL(string: book.coverURL ?? "")
                fetchDominantColor(from: coverURL) { color in
                    dominantColor = color
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
            .toolbarBackground(dominantColor, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showEditProgressSheet) {
                if let savedBook = book as? SavedBook {
                    EditProgressSheetView(book: savedBook)
                        .presentationDetents([.fraction(0.25), .medium])
                        .presentationDragIndicator(.visible)
                }
            }
        }
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


struct detailsGenreView<T: BookRepresentable> : View {
    var book: T
    @State private var genres: [BookGenre]? = nil
    @ObservedObject var viewModel: CombinedGenreSearchViewModel
    
    var body: some View {
        if let savedBook = book as? SavedBook {
            if let genres = savedBook.genres {
                Text("Genres (savedbook): \(genres.map { $0.rawValue }.joined(separator: ", "))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            } else {
                Text("Genres: None")
                    .foregroundColor(.secondary)
            }
        } else if book is BookAPI {
            if let genres = genres {
                Text("Genres (Api book): \(genres.map { $0.rawValue }.joined(separator: ", "))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
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

struct detailTAView<T: BookRepresentable> : View {
    @Binding var titleOffset: CGFloat
    @Binding var showNavTitle: Bool
    var book: T
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
            Text(book.authors.joined(separator: ", "))
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
    }
}
struct detailCoverView<T: BookRepresentable> : View {
    var book: T
    var body: some View {
        ZStack {
            if let urlString = book.coverURL {
                AsyncImageView(urlString: urlString)
                    .frame(width: 180, height: 280)
                    .cornerRadius(8)
                    .shadow(radius: 10)
                    .padding()
            } else {
                noBookCoverUrlView(width: 180, height: 180, bookTitle: book.title)
                    .cornerRadius(8)
                    .shadow(radius: 10)
                    .padding()
            }
        }
    }
}

struct RatingView : View {
    var book: SavedBook
    @Environment(\.modelContext) private var context

    var color: Color
    var maximumRating = 5
    var starSize: CGFloat = 24
    var allowsHalfStars = true
    @State var rating: Double

    
    var body: some View {
        
        if color ==  .gray.opacity(0.2) {
            HStack(spacing: 4) {
                ForEach(1...maximumRating, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: starSize, height: starSize)
                        .foregroundColor(.gray)
                        .shimmering()
                }
            }
        } else {
            HStack(spacing: 4) {
                ForEach(1...maximumRating, id: \.self) { index in
                    Image(systemName: starType(for: index))
                        .resizable()
                        .scaledToFit()
                        .frame(width: starSize, height: starSize)
                        .foregroundColor(color)
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
            Circle()
                .fill(book.readingStatus.color)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1)
                )
                .animation(.easeInOut(duration: 0.25), value: book.readingStatus)
        }
        .menuOrder(.fixed)
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


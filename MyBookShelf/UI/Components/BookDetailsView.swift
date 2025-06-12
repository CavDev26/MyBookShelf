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
    
    @ObservedObject var viewModel: CombinedGenreSearchViewModel

    @State private var genres: [BookGenre]? = nil

    
    var body: some View {
        ZStack(alignment: .top) {
            Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                .ignoresSafeArea()
            
            GeometryReader { outerGeo in
                ScrollView {
                    VStack(spacing: 0) {
                        ZStack {
                            if let urlString = book.coverURL, let url = URL(string: urlString) {
                                AsyncImageView(urlString: urlString)
                                    .frame(width: 180, height: 280)
                                    .cornerRadius(8)
                                    .shadow(radius: 10)
                                    .padding()
                            }
                        }
                        
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
                            
                            //if let desc = book.bookDescription {
                            Text(book.descriptionText ?? "non ho desc")
                                .font(.system(size: 20, weight: .light, design: .serif))
                                .padding(.horizontal, 8)
                            //}
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                Text("4.2 (123)")
                                //if let pages = book.pageCount {
                                Text("• \(book.pageCount) pages")
                                //}
                            }
                            .font(.caption)
                        }
                        
                        HStack(spacing: 16) {
                            Button("Sample") {
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Buy") {
                            }
                            .buttonStyle(.bordered)
                        }.padding()
                        
                        Divider().padding(.vertical)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: 30, weight: .semibold, design: .serif))
                                .bold()
                            ForEach(0..<10, id: \.self) { _ in
                                Text("Prova\n\n\n\n\n")
                            }
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
                }
                .toolbarBackground(dominantColor, for: .navigationBar)
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
                .navigationBarBackButtonHidden(true)
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


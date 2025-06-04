
import SwiftUI

struct AddBooksView: View {
    @Environment(\.colorScheme) var colorScheme
    //@State private var searchText: String = ""
    let columnCount: Int = 3
    let gridSpacing: CGFloat = -20.0
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                    .ignoresSafeArea()
                VStack {
                    TopNavBar{
                        ScanSearchBarView(scan: true, searchInLibrary: false)
                    }
                    ScrollView(.vertical) {
                        genreDiscoverView(gridSpacing: gridSpacing, columnCount: columnCount)
                        topPicksDiscoverView()
                    }
                }
            }
        }
    }
}

struct topPicksDiscoverView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationLink(
            destination: PlaceHolderView()
        ) {
            HStack {
                Text("Discover our Top picks")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Image(systemName: "chevron.right")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .font(.system(size: 18, weight: .semibold))
            }.padding(.top)
                .padding(.horizontal)
        }
        ScrollView(.horizontal) {
            HStack {
                ForEach (0..<6) { i in
                    RoundedRectangle(cornerSize: .zero).frame(width: 100, height: 100).padding()
                }
            }
        }
    }
}

struct genreDiscoverView: View {
    @Environment(\.colorScheme) var colorScheme
    let genreImages = ["Scifi", "ComicsManga", "Horror", "Crime", "Fantasy", "Classics"]
    var gridSpacing: CGFloat
    var columnCount: Int
    
    var body: some View {
        NavigationLink(
            destination: PlaceHolderView()
        ) {
            HStack {
                Text("Discover by genre")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Image(systemName: "chevron.right")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .font(.system(size: 18, weight: .semibold))
            }.padding(.top)
                .padding(.horizontal)
        }
        
        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: gridSpacing), count: columnCount), spacing: gridSpacing) {
            ForEach (genreImages, id: \.self) { imageName in
                NavigationLink(
                    destination: PlaceHolderView()
                ) {
                    genreView(imageName: imageName)
                }
            }
        }
    }
}

struct genreView: View {
    var imageName: String
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit) // mantiene il rapporto originale
            .cornerRadius(12)
            .clipped()
            .shadow(radius: 4)
            .padding()
    }
}


#Preview {
    AddBooksView()
}

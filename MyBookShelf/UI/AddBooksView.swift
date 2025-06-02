
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
                        Text("Discover by genre")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top)
                        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: gridSpacing), count: columnCount), spacing: gridSpacing) {
                            ForEach (0..<6) { i in
                                RoundedRectangle(cornerSize: .zero).frame(width: 100, height: 100).padding()
                            }
                        }
                        Text("Discover top picks")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach (0..<6) { i in
                                    RoundedRectangle(cornerSize: .zero).frame(width: 100, height: 100).padding()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


#Preview {
    AddBooksView()
}

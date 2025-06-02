import SwiftUI
import _SwiftData_SwiftUI

struct HomeView: View {

    @Environment(\.colorScheme) var colorScheme
    @StateObject private var vm = ViewModel()
    let columnCount: Int = 3
    let gridSpacing: CGFloat = -20.0
    @Query(sort: \Book.name, order: .forward) var books: [Book]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(colorScheme == .dark ? vm.backgroundColorDark : vm.lightColorApp)
                    .ignoresSafeArea()
                
                VStack{
                    ZStack(alignment: .top) {
                        TopNavBar {
                            Image("MyIcon").resizable().frame(width: 50, height:50)
                            Text("MyBookShelf").frame(maxWidth: .infinity, alignment:.leading).font(.custom("Baskerville-SemiBoldItalic", size: 20))
                        }
                    }
                    ScrollView(.vertical, showsIndicators: false) {
                        Text("Your progress")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top)
                        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: gridSpacing), count: columnCount), spacing: gridSpacing) {
                            
                            ForEach(books) { book in
                                if (book.readingStatus == .reading) {
                                    NavigationLink(
                                        destination: BookDetailsView(book: book)
                                    ) {
                                        BookListItemGrid(book: book, showStatus: true)
                                            .aspectRatio(2/4, contentMode: .fit)
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                    }
                                }
                            }
                            BlankBookPlaceHolderView()
                                .aspectRatio(2/4, contentMode: .fit)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        }
                        
                        Text("Challenges")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top)
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
    HomeView().modelContainer(PreviewData.makeModelContainer())
}

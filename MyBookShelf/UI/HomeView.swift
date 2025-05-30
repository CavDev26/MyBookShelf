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
                Color(colorScheme == .dark ? vm.backgroundColorDark : vm.backgroundColorLight)
                    .ignoresSafeArea()
                    .opacity(colorScheme == .dark ? 1 : 0.5)
                
                VStack{
                    ZStack(alignment: .top) {
                        HStack (){
                            Image("MyIcon").resizable().frame(width: 50, height:50).padding(.leading)
                            Text("MyBookShelf").frame(maxWidth: .infinity, alignment:.leading).font(.custom("Baskerville-SemiBoldItalic", size: 20))
                        }
                        .frame(width: .infinity, height: 50)
                        .padding(.bottom)
                        .background {
                            Color(colorScheme == .dark ? vm.backgroundColorDark2 : vm.backgroundColorLight)
                                .ignoresSafeArea()
                        }
                    }
                    
                    
                    
                    ScrollView(.vertical) {
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

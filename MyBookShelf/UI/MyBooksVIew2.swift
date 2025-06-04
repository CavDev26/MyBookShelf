import SwiftData
import SwiftUI

struct MyBooksView2: View {
    
    @Environment(\.colorScheme) var colorScheme
    //@StateObject private var vm = ViewModel()
    @Environment(\.modelContext) private var modelContext
    @State var isViewGrid: Bool = true
    @State private var isExpanded = false
    @State var filterSheet = false
    @Namespace private var searchNamespace
    
    @Query(sort: \Book.name, order: .forward) var books: [Book]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                    .ignoresSafeArea()
                
                VStack {
                    ZStack(alignment: .top) {
                        TopNavBar {
                            TopBarView(isExpanded: $isExpanded, isViewGrid: $isViewGrid, searchNamespace: searchNamespace, filterSheet: $filterSheet)
                        }
                        .animation(.easeInOut, value: isExpanded)
                    }
                    ZStack {
                        if isViewGrid {
                            BookListViewGrid(books: books)
                                .transition(.opacity.combined(with: .scale))
                        } else {
                            BookListViewList(books: books)
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: isViewGrid)
                }
            }
        }
    }
}



struct TopBarView: View {
    
    @Binding var isExpanded: Bool
    @Binding var isViewGrid: Bool
    var searchNamespace: Namespace.ID
    @Binding var filterSheet: Bool
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var vm = ViewModel()
    
    var body: some View {
        if isExpanded {
            HStack(spacing: 8) {
                ScanSearchBarView(scan: false, searchInLibrary: true)
                    .matchedGeometryEffect(id: "search", in: searchNamespace)
                Button("Cancel") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded = false
                        vm.searchText = ""
                    }
                }
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        } else {
            HStack {
                Image("MyIcon")
                    .resizable()
                    .frame(width: 50, height: 50)
                Text("MyBooks")
                    .font(.custom("Baskerville-SemiBoldItalic", size: 20))
                    .padding(.leading, -10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    filterSheet.toggle()
                }
                label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                .modifier(TopBarButtonStyle())
                .sheet(isPresented: $filterSheet) {
                    AddBookSheet()
                }
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    .modifier(TopBarButtonStyle())
                    .matchedGeometryEffect(id: "search", in: searchNamespace)
                }
                .transition(.scale)
                
                Button(action: {
                    withAnimation(.snappy(duration: 0.2)) {
                        isViewGrid.toggle()
                    }
                }) {
                    Image(systemName: isViewGrid ? "rectangle.grid.1x2.fill" : "rectangle.grid.3x2.fill")
                        .contentTransition(.symbolEffect(.replace))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                .modifier(TopBarButtonStyle())
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


struct TopBarButtonStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .padding(8)
            .background(colorScheme == .dark ? .backgroundColorDark : Color(red: 244/255, green: 238/255, blue: 224/255))
        //TODO
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 1)
    }
}


#Preview {
    MyBooksView2().modelContainer(PreviewData.makeModelContainer())
}


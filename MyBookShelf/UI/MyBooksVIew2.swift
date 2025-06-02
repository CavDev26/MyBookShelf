import SwiftData
import SwiftUI

struct MyBooksView2: View {
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var vm = ViewModel()
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
                                Image("MyIcon")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                
                                Text("MyBookShelf")
                                    .font(.custom("Baskerville-SemiBoldItalic", size: 20))
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
                                
                                // 🔍 Bottone stilisticamente identico alla searchbar
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
                            }
                            
                            // 🔲 Grid/List toggle
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


struct TopBarButtonStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(colorScheme == .dark ? .backgroundColorDark : Color(red: 244/255, green: 238/255, blue: 224/255))
            //TODO
            .clipShape(Circle())
            .shadow(radius: 1)
    }
}


#Preview {
    MyBooksView2().modelContainer(PreviewData.makeModelContainer())
}


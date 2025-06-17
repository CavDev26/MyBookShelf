import SwiftData
//import FirebaseAuth
import SwiftUI

struct MyBooksView2: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var auth: AuthManager
    @State var isViewGrid: Bool = true
    @State private var isExpanded = false
    @Namespace private var searchNamespace
    @Binding var selectedTab: Int
    @State private var searchText = ""
    @StateObject private var viewModel = CombinedGenreSearchViewModel()

    @State private var selectedSort: FilterMenuView.SortOption = .title
    @State private var selectedFilter: FilterMenuView.FilterOption = .allItems
    @State private var selectedSortAD: FilterMenuView.SortAD = .ascending
    @State private var selectedReadingStatus : ReadingStatus = .all
    @State private var selectedGenre: BookGenre = .all
    
    @Query var books: [SavedBook]
    
    var filteredBooks: [SavedBook] {
        var result = books

        if !searchText.isEmpty {
            result = result.filter { book in
                let text = searchText.lowercased()
                return
                    book.title.lowercased().contains(text) ||
                    book.authors.joined(separator: ", ").lowercased().contains(text) ||
                    (book.publishedDate?.lowercased().contains(text) ?? false)
            }
        }
        
        switch selectedFilter {
        case .favorites:
            result = result.filter { $0.favourite }
        case .genre:
            if selectedGenre != .all {
                result = result.filter { $0.genres?.contains(selectedGenre) == true }
            }
            break
            //result = result.filter { $0.genre != nil } // personalizza
        case .readingStatus:
            if selectedReadingStatus != .all{
                result = result.filter { $0.readingStatus == selectedReadingStatus } //personalizza
            } else {
                
            }
        case .allItems:
            break
        }

        switch selectedSort {
        case .title:
            result = result.sorted { compare($0.title, $1.title) }
        case .author:
            result = result.sorted { compare($0.authors.first ?? "", $1.authors.first ?? "") }
        case .recentlyAdded:
            break
            //result = result.sorted { compare($0.dateAdded, $1.dateAdded) }
        case .length:
            result = result.sorted { compare($0.pageCount ?? 0, $1.pageCount ?? 0) }
        case .review:
            result = result.sorted { compare($0.rating ?? 0, $1.rating ?? 0) }
        }
        return result
    }
    func compare(_ a: String, _ b: String) -> Bool {
        let result = a.localizedCaseInsensitiveCompare(b)
        return selectedSortAD == .ascending ? (result == .orderedAscending) : (result == .orderedDescending)
    }
    func compare<T: Comparable>(_ a: T, _ b: T) -> Bool {
        selectedSortAD == .ascending ? (a < b) : (a > b)
    }
    
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                    .ignoresSafeArea()
                VStack {
                    ZStack(alignment: .top) {
                        TopNavBar {
                            TopBarView(isExpanded: $isExpanded, isViewGrid: $isViewGrid, searchNamespace: searchNamespace, searchText: $searchText, selectedSort: $selectedSort, selectedFilter: $selectedFilter, selectedSortAD: $selectedSortAD, selectedReadingStatus: $selectedReadingStatus, selectedGenre: $selectedGenre)
                        }
                        .animation(.easeInOut, value: isExpanded)
                    }
                    ZStack {
                        if isViewGrid {
                            BookListViewGrid(books: filteredBooks, selectedTab: $selectedTab, viewModel: viewModel)
                                .transition(.opacity.combined(with: .scale))
                        } else {
                            BookListViewList(books: filteredBooks, viewModel: viewModel)
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: isViewGrid)
                }
            }
        }.onAppear {
            if !auth.uid.isEmpty {
                FirebaseBookService.shared.syncBooksToLocal(for: auth.uid, context: modelContext)
            }
        }
    }
}



struct TopBarView: View {
    @Binding var isExpanded: Bool
    @Binding var isViewGrid: Bool
    var searchNamespace: Namespace.ID
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var vm = CombinedGenreSearchViewModel()
    @Binding var searchText: String
    @Binding var selectedSort: FilterMenuView.SortOption
    @Binding var selectedFilter: FilterMenuView.FilterOption
    @Binding var selectedSortAD: FilterMenuView.SortAD
    @Binding var selectedReadingStatus : ReadingStatus
    @Binding var selectedGenre: BookGenre

    
    var body: some View {
        if isExpanded {
            HStack(spacing: 8) {
                ScanSearchBarView(scan: false, searchText: $searchText, searchInLibrary: true)
                    .matchedGeometryEffect(id: "search", in: searchNamespace)
                Button("Cancel") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded = false
                        searchText = ""
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
                FilterMenuView(
                    selectedSort: $selectedSort,
                    selectedFilter: $selectedFilter,
                    selectedSortAD: $selectedSortAD,
                    selectedReadingStatus: $selectedReadingStatus,
                    selectedGenre: $selectedGenre
                )
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
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
            .frame(width: 25, height: 25)
            .padding(8)
            .background(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 1)
            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
    }
}

struct FilterMenuView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedSort: SortOption
    @Binding var selectedFilter: FilterOption
    @Binding var selectedSortAD: SortAD
    @Binding var selectedReadingStatus : ReadingStatus
    @Binding var selectedGenre: BookGenre
    
    var body: some View {
        Menu {
            Picker("Sort", selection: $selectedSort) {
                Label("Sort by Title", systemImage: "")
                    .tag(SortOption.title)
                Label("Sort by Author", systemImage: "")
                    .tag(SortOption.author)
                Label("Sort by Recently Added", systemImage: "")
                    .tag(SortOption.recentlyAdded)
                Label("Sort by Lenght", systemImage: "")
                    .tag(SortOption.length)
                Label("Sort by your Reviews", systemImage: "")
                    .tag(SortOption.review)
            }

            Menu {
                Picker("Filter", selection: $selectedFilter) {
                    Label("All Items", systemImage: "square.grid.2x2")
                        .tag(FilterOption.allItems)
                    Label("Favorites", systemImage: "bookmark")
                        .tag(FilterOption.favorites)
                    
                    Menu("Genre") {
                        ForEach(BookGenre.allCases, id: \.self) { genre in
                            Button {
                                selectedGenre = genre
                                selectedFilter = .genre
                            } label: {
                                Text(genre.rawValue.capitalized)
                            }
                        }
                    }
                }
                Menu("Reading Status") {
                    ForEach(ReadingStatus.filterableCases, id: \.self) { status in
                        Button {
                            selectedReadingStatus = status
                            selectedFilter = .readingStatus
                        } label: {
                            Label(status.rawValue.capitalized, systemImage: status.iconName)
                        }
                    }
                }
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
            }

            Picker("", selection: $selectedSortAD) {
                Label("Ascending", systemImage: "")
                    .tag(SortAD.ascending)
                Label("Descending", systemImage: "")
                    .tag(SortAD.descending)
            }

        } label: {
            Image(systemName: "arrow.up.arrow.down")
            //Image(systemName: "line.3.horizontal.decrease")
                .modifier(TopBarButtonStyle())
        }
    }
    
    enum SortAD {
        case ascending
        case descending
    }
    enum SortOption {
        case recentlyAdded
        case length
        case title
        case author
        case review
    }
    enum FilterOption {
        case allItems
        case favorites
        case genre
        case readingStatus
    }
}


#Preview {
    @Previewable @State var selectedTab = 1
    return MyBooksView2(selectedTab: $selectedTab)
        .modelContainer(PreviewData2.makeModelContainer())
}


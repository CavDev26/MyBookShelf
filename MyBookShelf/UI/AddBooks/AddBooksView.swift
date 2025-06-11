
import SwiftUI

struct AddBooksView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isSearching = false
    @StateObject private var viewModel = CombinedGenreSearchViewModel()
    //@State private var searchText: String = ""
    let columnCount: Int = 3
    let gridSpacing: CGFloat = -20.0
    @State var scanview = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                    .ignoresSafeArea()
                VStack {
                    TopNavBar {
                        DiscoverSearchBarView(
                            //searchText: $searchText,
                            isSearching: $isSearching,
                            viewModel: viewModel,
                            scanview: $scanview
                        )
                    }
                    if isSearching {
                        if viewModel.isLoading && viewModel.searchResults.isEmpty {
                            ProgressView().padding()
                            
                        } else {
                            ScrollViewReader { scrollProxy in
                                ScrollView(showsIndicators: false) {
                                    VStack {
                                        SearchResultList(books: viewModel.searchResults)
                                        if viewModel.loadedCount < viewModel.allTitles.count {
                                            LoadMoreButtonView(viewModel: viewModel, scrollProxy: scrollProxy, topPicks: false)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        ScrollView(showsIndicators: false) {
                            genreDiscoverView(gridSpacing: gridSpacing, columnCount: columnCount)
                            topPicksDiscoverView(viewModel: viewModel)
                            addBookManuallyView()
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}


struct addBookManuallyView: View {
    @State private var showSheet = false
    
    var body: some View {
        Button {
            showSheet.toggle()
        }
        label: {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue)
                .overlay{
                    Text("Add manually\n-\nDebug")
                        .foregroundColor(.white)
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .padding()
        .sheet(isPresented: $showSheet) {
            manualAddSheet()
                .presentationDetents([.fraction(0.25), .medium])
                .presentationDragIndicator(.visible)
        }
    }
}

struct manualAddSheet: View {
    @Environment(\.colorScheme) var colorScheme
    //@Binding var goal: Int?
    //@Binding var tempGoal: String
    //@Binding var showSheet: Bool
    //var goalName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add a book - Manually")
            /*Text(goalName)
             .font(.headline)
             .padding(.top, 30)
             TextField("Books you want to read", text: $tempGoal)
             .padding()
             .background(
             RoundedRectangle(cornerRadius: 10)
             .fill(colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.9))
             )
             .foregroundColor(colorScheme == .dark ? .white : .black)
             .keyboardType(.numberPad)
             .padding(.horizontal)
             
             Button("Save") {
             if let newGoal = Int(tempGoal), newGoal > 0 {
             goal = newGoal
             showSheet = false
             tempGoal = ""
             }
             }
             .font(.system(size: 17, weight: .semibold))
             .padding(.horizontal, 32)
             .padding(.vertical, 12)
             .background(Color.terracotta)
             .foregroundColor(.white)
             .clipShape(RoundedRectangle(cornerRadius: 10))
             //.buttonStyle(.borderedProminent)
             Spacer()
             }
             .padding()
             .padding(.top, 30)
             .onAppear {
             if let goal {
             tempGoal = "\(goal)"
             }*/
        }
    }
}


struct topPicksDiscoverView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: CombinedGenreSearchViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NavigationLink(destination: TopPicksVIew(viewModel: viewModel)) {
                HStack {
                    Text("Discover our top picks")
                        .font(.system(size: 18, weight: .semibold, design: .serif))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Image(systemName: "chevron.right")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .font(.system(size: 18, weight: .semibold))
                }.padding(.top)
                    .padding(.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    if viewModel.searchResultsBS.isEmpty {
                        ForEach(0..<10, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 150)
                                .redacted(reason: .placeholder)
                                .shimmering()
                        }
                    } else {
                        ForEach(viewModel.searchResultsBS.prefix(10)) { book in
                            NavigationLink {
                                BookDetailsView(book: book)
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
            if viewModel.searchResultsBS.isEmpty {
                viewModel.searchByBestSeller()
            }
        }
    }
}


struct genreDiscoverView: View {
    @Environment(\.colorScheme) var colorScheme
    let genreImages = ["Scifi", "Comics", "Horror", "Mistery", "Fantasy", "Classics"]
    var gridSpacing: CGFloat
    var columnCount: Int
    
    var body: some View {
        NavigationLink(
            destination: GenresView()
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
                let genre = BookGenre.fromImageName(imageName)
                NavigationLink(
                    destination: SingleSearchView(genre: genre)
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
            .aspectRatio(contentMode: .fit)
            .cornerRadius(12)
            .clipped()
            .shadow(radius: 4)
            .padding()
    }
}


#Preview {
    AddBooksView()
}

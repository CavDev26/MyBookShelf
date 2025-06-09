
import SwiftUI

struct AddBooksView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isSearching = false
    @StateObject private var viewModel = CombinedGenreSearchViewModel()
    @State private var searchText: String = ""
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
                            searchText: $searchText,
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
                                ScrollView {
                                    VStack {
                                        SearchResultList(books: viewModel.searchResults)

                                        if !viewModel.isLoading {
                                            Button {
                                                let oldCount = viewModel.searchResults.count
                                                let lastID = viewModel.searchResults.last?.id ?? UUID().uuidString
                                                viewModel.searchBooks(query: searchText, reset: false) { didLoadNew in
                                                    if didLoadNew {
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                                            withAnimation {
                                                                scrollProxy.scrollTo(lastID, anchor: .top)
                                                            }
                                                        }
                                                    }
                                                }
                                            } label: {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.terracotta)
                                                    .overlay {
                                                        Text("Load More")
                                                            .foregroundColor(.white)
                                                    }
                                                    .frame(width: 150, height: 50, alignment: .center)
                                                    .shadow(radius: 8)
                                            }
                                            .padding()
                                        } else {
                                            ProgressView().padding()
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        ScrollView {
                            genreDiscoverView(gridSpacing: gridSpacing, columnCount: columnCount)
                            topPicksDiscoverView()
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

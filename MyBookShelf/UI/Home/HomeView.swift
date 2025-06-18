import SwiftUI
import _SwiftData_SwiftUI

struct HomeView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var context
    @EnvironmentObject var auth: AuthManager

    let columnCount: Int = 3
    let gridSpacing: CGFloat = 20.0
    @Query(sort: \SavedBook.title, order: .forward) var books: [SavedBook]
    //var books: [SavedBook] = []
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                    .ignoresSafeArea()
                VStack{
                    ZStack(alignment: .top) {
                        TopNavBar {
                            Image("MyIcon").resizable().frame(width: 50, height:50)
                            Text("MyBookShelf")
                                .padding(.leading, -10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.custom("Baskerville-SemiBoldItalic", size: 20))
                        }
                    }
                    ScrollView(.vertical, showsIndicators: false) {
                        yourProgressView(books: books, gridSpacing: gridSpacing, columnCount: columnCount, selectedTab: $selectedTab)
                        challengesPreview()
                    }
                }
            }
        }
        .onAppear{
            if !auth.uid.isEmpty {
                FirebaseBookService.shared.syncBooksToLocal(for: auth.uid, context: context)
            }
        }
    }
}

struct challengesPreview: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationLink(destination: ChallengesView()
        ) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.terracotta)
                    .frame(width: 4, height: 20)
                
                Text("Challenges & Achievements")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding(.horizontal)
            .padding(.top)
        }
        
        HStack(spacing: 16) {
            NavigationLink(destination: ChallengesView()) {
                VStack(spacing: 4) {
                    SingleRingProgress(progress: 0.75, current: 18, goal: 24, small: true)
                        .padding()
                    Text("2025 Goal")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            NavigationLink(destination: ChallengesView()) {
                VStack(spacing: 4) {
                    SingleRingProgress(progress: 0.33, current: 1, goal: 3, small: true)
                        .padding()
                    Text("June Goal")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            NavigationLink(destination: StatsView()) {
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                            .frame(width: 60, height: 60)
                        Circle()
                            .trim(from: 0, to: 1.0)
                            .stroke(Color.terracotta, lineWidth: 10)
                            .frame(width: 60, height: 60)
                            .opacity(0.2)
                        
                        Image(systemName: "chart.bar.xaxis")
                            .foregroundColor(.terracotta)
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .padding()
                    Text("Stats")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                //.padding()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.backgroundColorLight.opacity(0.8))
        )
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
}


struct yourProgressView: View {
    var books: [SavedBook]
    var gridSpacing: CGFloat
    var columnCount: Int
    @Binding var selectedTab: Int
    @StateObject private var viewModel = CombinedGenreSearchViewModel()

    var body: some View {
        VStack{
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.terracotta)
                    .frame(width: 4, height: 20)
                
                Text("Your Progress")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
            
            
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: gridSpacing), count: columnCount), spacing: gridSpacing) {
                
                ForEach(books) { book in
                    if (book.readingStatus == .reading) {
                        VStack {
                            
                            
                            
                            NavigationLink(
                                destination: BookDetailsView(book: book, viewModel: viewModel)
                            ) {
                                BookListItemGrid(book: book, showStatus: true)
                                    .aspectRatio(2/3, contentMode: .fill)
                            }
                            
                            
                            progressViewBook(book: book, viewModel: viewModel)
                                .padding(.top, -10)
                        }
                    }
                }
                if books.count(where: { $0.readingStatus == .reading }) < 3 {
                    BlankBookPlaceHolderView(selectedTab: $selectedTab)
                        .aspectRatio(2/4, contentMode: .fill)
                }            }
        }
        .padding(.horizontal)
    }
}

struct progressViewBook: View {
    @State var size: CGSize = .zero
    var book: SavedBook
    @ObservedObject var viewModel: CombinedGenreSearchViewModel

    @Environment(\.colorScheme) var colorScheme
    
    var progress: CGFloat {
        guard let pageCount = book.pageCount, pageCount > 0 else { return 0 }
        return CGFloat(book.pagesRead) / CGFloat(pageCount)
    }
    
    var body: some View {
        
        NavigationLink (
            destination: BookDetailsView(book: book, openSheetOnAppear: true, viewModel: viewModel)) {
        
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(height: 8)
                    .saveSize(in: $size)
                
                Capsule()
                    .fill(Color.terracottaDarkIcons)
                    .frame(width: progress * size.width, height: 8)
                    .animation(.easeInOut(duration: 0.5), value: book.pagesRead)
                
            }.padding(.top)
            

                HStack {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(colorScheme == .dark ? Color.terracotta : Color.backgroundColorLight)
                            .overlay {
                                Text("Update")
                                    .font(.system(size: 12, weight: .semibold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .foregroundColor(Color.secondary)
                                    .padding(4)
                            }
                }
            }
        }
    }
}



#Preview {
    @Previewable @State var selectedTab = 0
    HomeView(selectedTab: $selectedTab).modelContainer(PreviewData2.makeModelContainer())
}

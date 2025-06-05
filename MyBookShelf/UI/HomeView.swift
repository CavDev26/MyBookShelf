import SwiftUI
import _SwiftData_SwiftUI

struct HomeView: View {
    
    @Environment(\.colorScheme) var colorScheme
    let columnCount: Int = 3
    let gridSpacing: CGFloat = -20.0
    @Query(sort: \Book.name, order: .forward) var books: [Book]
    
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
                        yourProgressView(books: books, gridSpacing: gridSpacing, columnCount: columnCount)
                        challengesPreview()
                        /*NavigationLink(destination: BookSearchDebugView(), label: {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.blue)
                                .overlay{
                                    Text("test per api")
                                        .foregroundColor(.white)
                                }
                                .frame(width: 100, height: 100)
                        })*/
                    }
                }
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
    var books : [Book]
    var gridSpacing: CGFloat
    var columnCount: Int
    
    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.terracotta)
                .frame(width: 4, height: 20)
            
            Text("Your Progress")
                .font(.system(size: 20, weight: .semibold, design: .serif))
        }
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
                .aspectRatio(2/4, contentMode: .fill)
                .padding(.horizontal)
                .padding(.vertical, 8)
        }
    }
}


#Preview {
    HomeView().modelContainer(PreviewData.makeModelContainer())
}

import SwiftUI

struct GenresView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    //@StateObject private var viewModel = BookSearchViewModel()
    let genres = BookGenre.allCases.filter { $0 != .unknown }

    var body: some View {
        
        NavigationStack {
            ZStack(alignment: .top) {
                Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                    .ignoresSafeArea()
                VStack {
                    /*TopNavBar {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }*/
                    ScrollView {
                        VStack(spacing: 1) {
                            ForEach(genres, id: \.self) { genre in
                                NavigationLink(destination: SingleSearchView(genre: genre)) {
                                    HStack {
                                        Text(formatGenreName(genre))
                                            .font(.system(size: 17, weight: .regular, design: .serif))
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.backgroundColorLight)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .customNavigationTitle("Genres")
    }
    
    func formatGenreName(_ genre: BookGenre) -> String {
        let raw = genre.rawValue
        return raw
            .replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
            .capitalized
    }
}

#Preview {
    AddBooksView()
}

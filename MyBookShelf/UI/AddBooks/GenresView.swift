import SwiftUI

struct GenresView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    let genres = BookGenre.allCases.filter { $0 != .unknown && $0 != .all }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(genres, id: \.self) { genre in
                            NavigationLink(destination: SingleSearchView(genre: genre)) {
                                HStack {
                                    Text(formatGenreName(genre))
                                        .font(.system(size: 17, weight: .semibold, design: .serif))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .customNavigationTitle("Genres")
    }
    
    func formatGenreName(_ genre: BookGenre) -> String {
        genre.rawValue
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
    }
}

#Preview {
    AddBooksView()
}

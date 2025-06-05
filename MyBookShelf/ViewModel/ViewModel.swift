import Foundation
import SwiftUICore

class ViewModel: ObservableObject {
    @Published var searchText: String = ""

    
}

class BookSearchViewModel: ObservableObject {
    @Published var searchResults: [BookAPI] = []
    @Published var isLoading = false

    func searchBooks(query: String) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(encodedQuery)"

        guard let url = URL(string: urlString) else { return }
        isLoading = true

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(BooksAPIResponse.self, from: data)
                DispatchQueue.main.async {
                    self.searchResults = (decoded.items ?? []).map { BookAPI(from: $0) }
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
}

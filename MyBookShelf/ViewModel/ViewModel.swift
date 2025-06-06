import Foundation
import SwiftUICore

class ViewModel: ObservableObject {
    @Published var searchText: String = ""

    
}





class BookSearchViewModel: ObservableObject {
    @Published var searchResults: [BookAPI] = []
    @Published var isLoading = false

    func searchBooksByGenre(query: String = "", genre: String? = nil) {
        var fullQuery = query
        
        if let genre = genre, !genre.isEmpty {
            fullQuery = "subject:\(genre)"
        }

        guard let encodedQuery = fullQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(encodedQuery)&maxResults=40"
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
                    //self.searchResults = (decoded.items ?? []).map { BookAPI(from: $0) }
                    
                    self.searchResults = (decoded.items ?? [])
                        .map { BookAPI(from: $0) }
                        .filter { book in
                            book.categories?.contains { $0.localizedCaseInsensitiveContains(genre ?? "") } ?? false
                        }
                    
                    /*self.searchResults = (decoded.items ?? [])
                        .map { BookAPI(from: $0) }
                        .filter { book in
                            book.categories?.contains { $0.localizedCaseInsensitiveContains(genre ?? "") } ?? false
                        }*/
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
    
    
    
    
    
    
    
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

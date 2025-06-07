import Foundation
import SwiftUICore
import Combine

class ViewModel: ObservableObject {
    @Published var searchText: String = ""
 
}

class CombinedGenreSearchViewModel: ObservableObject {
    @Published var searchResults: [BookAPI] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private var allTitles: [String] = []
    private var loadedCount: Int = 0
    
    func loadMore(batchSize: Int = 30) {
        guard !isLoading else {
            print("⚠️ Caricamento già in corso")
            return
        }

        guard loadedCount < allTitles.count else {
            print("✅ Nessun altro titolo da caricare (loadedCount: \(loadedCount))")
            return
        }

        let nextBatch = Array(allTitles.dropFirst(loadedCount).prefix(batchSize))
        loadedCount += nextBatch.count

        print("🔄 Carico batch da \(nextBatch.count) titoli (loadedCount: \(loadedCount))")

        isLoading = true // <-- SPOSTATO DOPO il controllo

        fetchBooksFromGoogle(titles: nextBatch)
    }
    
    func searchByGenreSmart(genre: String) {
        searchResults = []
        allTitles = []
        loadedCount = 0
        isLoading = false // ✅ Assicuriamoci che non blocchi loadMore
        
        fetchTitlesFromOpenLibrary(genre: genre) { titles in
            DispatchQueue.main.async {
                self.allTitles = titles
                print("📚 Found \(titles.count) titles from OpenLibrary")
                print("📚 First titles: \(titles.prefix(5))")
                self.loadMore() // ✅ Ora può partire correttamente
                print("🚀 Chiamata loadMore() con \(self.allTitles.count) titoli totali")
            }
        }
    }
    
    private func fetchTitlesFromOpenLibrary(genre: String, completion: @escaping ([String]) -> Void) {
        let genreQuery = genre.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://openlibrary.org/subjects/\(genreQuery).json?limit=100"
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid OpenLibrary URL")
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                print("❌ No data from OpenLibrary")
                completion([])
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(OpenLibrarySubjectResponse.self, from: data)
                let titles = decoded.works.map { $0.title }
                completion(titles)
            } catch {
                print("❌ Decoding error OpenLibrary: \(error)")
                completion([])
            }
        }.resume()
    }
    
    private func fetchBooksFromGoogle(titles: [String]) {
        print("📤 Fetching batch of \(titles.count) titoli da Google")
        let group = DispatchGroup()
        var books: [BookAPI] = []
        
        for title in titles {
            group.enter()
            print("🔍 Tentativo fetch per: \(title)")
            let query = "intitle:\(title)"
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(encoded)"
            
            guard let url = URL(string: urlString) else {
                print("❌ Invalid URL for title: \(title)")
                group.leave()
                continue
            }
            
            URLSession.shared.dataTask(with: url) { data, _, _ in
                defer { group.leave() }
                
                guard let data = data else {
                    print("❌ No data from Google for title: \(title)")
                    return
                }
                
                if let decoded = try? JSONDecoder().decode(BooksAPIResponse.self, from: data),
                   let item = decoded.items?.first {
                    let book = BookAPI(from: item)
                    books.append(book)
                    print("✅ Found book: \(book.title)")
                } else {
                    print("⚠️ No match from Google for title: \(title)")
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            self.searchResults.append(contentsOf: books)
            self.isLoading = false
            print("📦 Aggiunti \(books.count) libri ai risultati")
            if books.isEmpty {
                print("❌ Nessun libro trovato nel batch Google")
            }
        }
    }
}

// MARK: - Open Library Models
struct OpenLibrarySubjectResponse: Codable {
    let works: [OpenLibraryWork]
}

struct OpenLibraryWork: Codable {
    let title: String
}

/*class CombinedGenreSearchViewModel: ObservableObject {
    @Published var searchResults: [BookAPI] = []
    @Published var isLoading = false

    private var cancellables = Set<AnyCancellable>()

    func searchByGenreSmart(genre: String) {
        isLoading = true
        searchResults = []

        fetchTitlesFromOpenLibrary(genre: genre) { titles in
            if titles.isEmpty {
                DispatchQueue.main.async { self.isLoading = false }
            } else {
                self.fetchBooksFromGoogle(titles: titles)
            }
        }
    }

    private func fetchTitlesFromOpenLibrary(genre: String, completion: @escaping ([String]) -> Void) {
        let genreQuery = genre.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://openlibrary.org/subjects/\(genreQuery).json?limit=30"

        guard let url = URL(string: urlString) else {
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion([])
                return
            }

            do {
                let decoded = try JSONDecoder().decode(OpenLibrarySubjectResponse.self, from: data)
                let titles = decoded.works.map { $0.title }
                completion(titles)
            } catch {
                completion([])
            }
        }.resume()
    }

    private func fetchBooksFromGoogle(titles: [String]) {
        let group = DispatchGroup()
        var books: [BookAPI] = []

        for title in titles.prefix(20) {
            group.enter()

            let query = "intitle:\(title)"
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(encoded)"

            guard let url = URL(string: urlString) else {
                group.leave()
                continue
            }

            URLSession.shared.dataTask(with: url) { data, _, _ in
                defer { group.leave() }
                guard let data = data,
                      let decoded = try? JSONDecoder().decode(BooksAPIResponse.self, from: data),
                      let item = decoded.items?.first else { return }

                let book = BookAPI(from: item)
                books.append(book)
            }.resume()
        }

        group.notify(queue: .main) {
            self.searchResults = books
            self.isLoading = false
        }
    }
}

// MARK: - Open Library Models
struct OpenLibrarySubjectResponse: Codable {
    let works: [OpenLibraryWork]
}

struct OpenLibraryWork: Codable {
    let title: String
}
*/



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
                    
                    self.searchResults = (decoded.items ?? [])
                        .map { BookAPI(from: $0) }
                        /*.filter { book in
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

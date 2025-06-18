import Foundation
import SwiftData
import AVFoundation
import SwiftUICore
import Combine
import FirebaseAuth





extension ModelContext {
    func saveAndSync(for uid: String) throws {
        try self.save()

        let allBooks = try self.fetch(FetchDescriptor<SavedBook>())
        for book in allBooks {
            let firestoreBook = FirebaseBookMapper.toFirestore(book)
            FirebaseBookService.shared.upload(book: firestoreBook, for: uid)
        }

        print("✅ Synced all local books to Firestore")
    }
}





class CombinedGenreSearchViewModel: ObservableObject {
    @Published var searchResults: [BookAPI] = []
    @Published var searchResultsBS: [BookAPI] = []
    @Published var searchResultsRelated: [BookAPI] = []
    @Published var searchResultsAuthor: [BookAPI] = []
    
    @Published var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    @Published var allTitles: [String] = []
    @Published var loadedCount: Int = 0
    @Published var searchText: String = ""
    
    private var currentAuthorStartIndex: Int = 0
    private var currentAuthorQuery: String = ""
    
    
    func searchBooksByAuthor(_ author: String, reset: Bool = true, completion: ((Bool) -> Void)? = nil) {
        if reset {
            currentAuthorQuery = author
            currentAuthorStartIndex = 0
            searchResultsAuthor = []
        }

        fetchBooksByAuthorPaginated(completion: completion)
    }
    private func fetchBooksByAuthorPaginated(completion: ((Bool) -> Void)? = nil) {
        guard !currentAuthorQuery.isEmpty else {
            completion?(false)
            return
        }

        let query = "inauthor:\(currentAuthorQuery)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(query)&startIndex=\(currentAuthorStartIndex)&maxResults=20"

        guard let url = URL(string: urlString) else {
            completion?(false)
            return
        }

        isLoading = true
        URLSession.shared.dataTask(with: url) { data, _, error in
            defer {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }

            guard let data = data, error == nil,
                  let decoded = try? JSONDecoder().decode(BooksAPIResponse.self, from: data) else {
                completion?(false)
                return
            }

            let books = (decoded.items ?? []).map { BookAPI(from: $0) }
            DispatchQueue.main.async {
                self.searchResultsAuthor.append(contentsOf: books)
                self.currentAuthorStartIndex += 20
                completion?(true)
            }
        }.resume()
    }
    
    
    
    
    
    
    init() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self, !text.isEmpty else { return }
                print("⏱ Debounced search: \(text)")
                self.searchBooks(query: text, reset: true)
            }
            .store(in: &cancellables)
    }
    
    
    private var currentStartIndex: Int = 0
    var currentQuery: String = ""
    private let pageSize: Int = 20
    
    func loadMore(topPicks: Bool, batchSize: Int = 30, completion: (() -> Void)? = nil) {
        guard !isLoading else { return }
        guard loadedCount < allTitles.count else {
            completion?()
            return
        }
        
        let nextBatch = Array(allTitles.dropFirst(loadedCount).prefix(batchSize))
        loadedCount += nextBatch.count
        isLoading = true
        
        fetchBooksFromGoogle(titles: nextBatch, topPicks: topPicks) {
            completion?()
        }
    }
    
    func searchByGenreSmart(genre: String) {
        searchResults = []
        allTitles = []
        loadedCount = 0
        isLoading = false
        
        fetchTitlesFromOpenLibrary(genre: genre) { titles in
            DispatchQueue.main.async {
                self.allTitles = titles
                self.loadMore(topPicks: false)
            }
        }
    }
    
    private func fetchTitlesFromOpenLibrary(genre: String, completion: @escaping ([String]) -> Void) {
        let genreQuery = genre.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://openlibrary.org/subjects/\(genreQuery).json?limit=100"
        
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
    
    private func fetchBooksFromGoogle(titles: [String], topPicks: Bool, completion: @escaping () -> Void) {
        let group = DispatchGroup()
        var books: [BookAPI] = []
        
        for title in titles {
            group.enter()
            let query = "intitle:\(title)"
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(encoded)"
            print("📡 Requesting Google API for: \(title)")
            guard let url = URL(string: urlString) else {
                group.leave()
                continue
            }
            URLSession.shared.dataTask(with: url) { data, _, _ in
                defer { group.leave() }
                guard let data = data else { return }
                if let decoded = try? JSONDecoder().decode(BooksAPIResponse.self, from: data),
                   let item = decoded.items?.first {
                    let book = BookAPI(from: item)
                    books.append(book)
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            DispatchQueue.main.async {
                if topPicks {
                    self.searchResultsBS.append(contentsOf: books)
                } else {
                    self.searchResults.append(contentsOf: books)
                }
                self.isLoading = false
                completion()
            }
        }
    }
    
    
    
    
    
    
    func searchBooks(query: String, reset: Bool = true, completion: ((Bool) -> Void)? = nil) {
        guard !query.isEmpty else {
            completion?(false)
            return
        }
        print("🔍 Ricerca per query: \(query), reset: \(reset)")
        if reset {
            currentQuery = query
            currentStartIndex = 0
            searchResults = []
        }
        loadMoreSearchResults(completion: completion)
    }
    
    func loadMoreSearchResults(completion: ((Bool) -> Void)? = nil) {
        guard !isLoading else {
            print("⚠️ Already loading")
            completion?(false)
            return
        }
        
        guard !currentQuery.isEmpty else {
            print("❌ No current query set")
            completion?(false)
            return
        }
        
        isLoading = true
        
        let encodedQuery = currentQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(encodedQuery)&startIndex=\(currentStartIndex)&maxResults=\(pageSize)"
        print("🌐 Requesting: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            isLoading = false
            completion?(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            defer {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            
            if let error = error {
                print("❌ Request error: \(error)")
                completion?(false)
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                completion?(false)
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(BooksAPIResponse.self, from: data)
                let newBooks = (decoded.items ?? []).map { BookAPI(from: $0) }
                
                DispatchQueue.main.async {
                    if !newBooks.isEmpty {
                        self.searchResults.append(contentsOf: newBooks)
                        self.currentStartIndex += self.pageSize
                        print("📚 Added \(newBooks.count) new books (total: \(self.searchResults.count))")
                        completion?(true)
                    } else {
                        completion?(false)
                    }
                }
            } catch {
                print("❌ Decoding error: \(error)")
                completion?(false)
            }
        }.resume()
    }
    
    
    
    
    
    func fetchBookScannerOnly(for isbn: String) {
        //let group = DispatchGroup()
        //var newBooks: [BookAPI] = []
        guard let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let decoded = try JSONDecoder().decode(BooksAPIResponse.self, from: data)
                let newBooks = (decoded.items ?? []).map { BookAPI(from: $0) }
                
                DispatchQueue.main.async {
                    if !newBooks.isEmpty {
                        self.searchResults.append(contentsOf: newBooks)
                        self.currentStartIndex += self.pageSize
                        print("📚 Added \(newBooks.count) new books (total: \(self.searchResults.count))")
                    }
                }
            } catch {
                print("❌ Decoding error: \(error)")
            }
        }.resume()
    }
    
    
    
    
    
    
    
    
    
    private func fetchTitlesFromOpenLibraryGeneric(completion: @escaping ([String]) -> Void) {
        let urlString = "https://openlibrary.org/search.json?q=a&sort=readinglog&limit=100"
        
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
                let decoded = try JSONDecoder().decode(OpenLibrarySearchResponse.self, from: data)
                let titles = decoded.docs.map { $0.title }
                print("📘 Titoli estratti da OpenLibrary: \(titles.prefix(10))")
                completion(titles)
            } catch {
                completion([])
            }
        }.resume()
    }
    
    func searchByBestSeller(completion: (() -> Void)? = nil) {
        searchResultsBS = []
        allTitles = []
        loadedCount = 0
        isLoading = false
        
        fetchTitlesFromOpenLibraryGeneric() { titles in
            DispatchQueue.main.async {
                self.allTitles = titles
                self.loadMore(topPicks: true)
            }
        }
    }
    
    
    
    
    func fetchGenreFromOpenLibrary(title: String, completion: @escaping ([BookGenre]?) -> Void) {
        let query = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let searchURL = URL(string: "https://openlibrary.org/search.json?title=\(query)&limit=1")!

        URLSession.shared.dataTask(with: searchURL) { data, _, _ in
            guard let data = data,
                  let decoded = try? JSONDecoder().decode(OpenLibrarySearchResponse.self, from: data),
                  let workKey = decoded.docs.first?.key else {
                completion([.unknown])
                return
            }

            let workURL = URL(string: "https://openlibrary.org\(workKey).json")!
            URLSession.shared.dataTask(with: workURL) { data, _, _ in
                guard let data = data,
                      let workDetails = try? JSONDecoder().decode(OpenLibraryWorkDetail.self, from: data),
                      let subjects = workDetails.subjects else {
                    completion([.unknown])
                    return
                }
                let genres = subjects.compactMap { BookGenre.fromOpenLibrarySubject($0) }
                completion(genres)
            }.resume()
        }.resume()
    }
    
    
    
    
    
    
    
    func saveBook(_ book: BookAPI, context: ModelContext) {
        let saved = SavedBook(from: book)
        context.insert(saved)
        do {
            try context.save()
            print("✅ Saved: \(saved.title)")
            
            // 🔥 Upload iniziale senza generi
            if let uid = Auth.auth().currentUser?.uid {
                let firestoreBook = FirebaseBookMapper.toFirestore(saved)
                FirebaseBookService.shared.upload(book: firestoreBook, for: uid)
            }
        } catch {
            print("❌ Save error: \(error)")
        }
        fetchGenreFromOpenLibrary(title: book.title) { genre in
            guard let genre else { return }

            DispatchQueue.main.async {
                saved.genres = genre
                do {
                    try context.save()
                    print("✅ Genre saved: \(genre)")
                    
                    // 🔁 Upload aggiornato con genere
                    if let uid = Auth.auth().currentUser?.uid {
                        let firestoreBook = FirebaseBookMapper.toFirestore(saved)
                        FirebaseBookService.shared.upload(book: firestoreBook, for: uid)
                    }
                } catch {
                    print("❌ Error saving genre: \(error)")
                }
            }
        }
    }
    
    
    
    
    
    
    func fetchBooksFromAuthor(title: String, authors: [String]) {
        let queries = authors.map { "inauthor:\($0)" }
        let fullQuery = queries.joined(separator: " OR ")
        guard let query = fullQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("❌ Invalid query encoding")
            self.searchResultsAuthor = []
            return
        }

        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(query)&maxResults=20"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            self.searchResultsAuthor = []
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Error fetching author's books: \(error)")
                DispatchQueue.main.async {
                    self.searchResultsAuthor = []
                }
                return
            }

            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async {
                    self.searchResultsAuthor = []
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(BooksAPIResponse.self, from: data)
                let filtered = (decoded.items ?? [])
                    .map { BookAPI(from: $0) }
                    .filter { apiBook in
                        // Esclude il libro stesso
                        apiBook.title.localizedCaseInsensitiveCompare(title) != .orderedSame
                    }

                DispatchQueue.main.async {
                    self.searchResultsAuthor = filtered
                }
            } catch {
                print("❌ Decoding error: \(error)")
                DispatchQueue.main.async {
                    self.searchResultsAuthor = []
                }
            }
        }.resume()
    }
    
    func fetchRelatedBooks(title: String, authors: [String]) {
        let query = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(query)&maxResults=20"

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            self.searchResultsRelated = []
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching related books: \(error)")
                DispatchQueue.main.async {
                    self.searchResultsRelated = []
                }
                return
            }

            guard let data = data else {
                print("❌ No data received")
                DispatchQueue.main.async {
                    self.searchResultsRelated = []
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(BooksAPIResponse.self, from: data)
                let filtered = (decoded.items ?? [])
                    .map { BookAPI(from: $0) }
                    .filter { apiBook in
                        // Esclude gli stessi autori
                        !apiBook.authors.contains { author in
                            authors.contains { inputAuthor in
                                inputAuthor.localizedCaseInsensitiveCompare(author) == .orderedSame
                            }
                        }
                    }

                DispatchQueue.main.async {
                    self.searchResultsRelated = filtered
                }
            } catch {
                print("❌ Decoding error: \(error)")
                DispatchQueue.main.async {
                    self.searchResultsRelated = []
                }
            }
        }.resume()
    }
    
    
}

struct OpenLibraryWorkDetail: Decodable {
    let subjects: [String]?
}

struct OpenLibraryDoc: Decodable {
    let title: String
    let key: String
    let subject: [String]?
}
struct OpenLibrarySearchResponse: Decodable {
    let docs: [OpenLibraryDoc]
}

struct OpenLibraryTrendingResponse: Codable {
    let works: [OpenLibraryWork]
}

// MARK: - Open Library Models
struct OpenLibrarySubjectResponse: Codable {
    let works: [OpenLibraryWork]
}

struct OpenLibraryWork: Codable {
    let title: String
}








final class ScannerViewModel: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var scannedCode: String?
    
    private let session = AVCaptureSession()
    private let metadataOutput = AVCaptureMetadataOutput()
    private var isConfigured = false  // ✅
    
    func startScanning() {
        if !isConfigured {
            configureSession()
        }
        DispatchQueue.global(qos: .userInitiated).async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func resetScan() {
        scannedCode = nil
        DispatchQueue.global(qos: .userInitiated).async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stopScanning() {
        session.stopRunning()
    }
    
    private func configureSession() {
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoInput),
              session.canAddOutput(metadataOutput)
        else {
            return
        }
        
        session.addInput(videoInput)
        session.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.ean13, .qr]
        isConfigured = true
    }
    
    func restartIfNeeded() {
        if !session.isRunning {
            startScanning()
        }
    }
    
    func getSession() -> AVCaptureSession {
        return session
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadata.stringValue else {
            return
        }
        scannedCode = stringValue
        //stopScanning()
    }
}


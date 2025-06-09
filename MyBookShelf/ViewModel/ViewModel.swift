import Foundation
import AVFoundation
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
    
    
    private var currentStartIndex: Int = 0
    var currentQuery: String = ""
    private let pageSize: Int = 20
    
    func loadMore(batchSize: Int = 30, completion: (() -> Void)? = nil) {
        guard !isLoading else { return }
        guard loadedCount < allTitles.count else {
            completion?()
            return
        }

        let nextBatch = Array(allTitles.dropFirst(loadedCount).prefix(batchSize))
        loadedCount += nextBatch.count
        isLoading = true

        fetchBooksFromGoogle(titles: nextBatch) {
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
                self.loadMore()
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
    
    private func fetchBooksFromGoogle(titles: [String], completion: @escaping () -> Void) {
        let group = DispatchGroup()
        var books: [BookAPI] = []

        for title in titles {
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
                guard let data = data else { return }
                if let decoded = try? JSONDecoder().decode(BooksAPIResponse.self, from: data),
                   let item = decoded.items?.first {
                    let book = BookAPI(from: item)
                    books.append(book)
                }
            }.resume()
        }

        group.notify(queue: .main) {
            self.searchResults.append(contentsOf: books)
            self.isLoading = false
            completion()
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

        isLoading = true

        let encodedQuery = currentQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(encodedQuery)&startIndex=\(currentStartIndex)&maxResults=\(pageSize)"

        guard let url = URL(string: urlString) else {
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
                        print("📚 Aggiunti \(newBooks.count) nuovi libri")
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

    func loadMoreSearchResults() {
        guard !isLoading else {
            print("⚠️ Already loading")
            return
        }

        guard !currentQuery.isEmpty else {
            print("❌ No current query set")
            return
        }

        isLoading = true

        let encodedQuery = currentQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(encodedQuery)&startIndex=\(currentStartIndex)&maxResults=\(pageSize)"
        print("🌐 Requesting: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            isLoading = false
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
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(BooksAPIResponse.self, from: data)
                let newBooks = (decoded.items ?? []).map { BookAPI(from: $0) }

                DispatchQueue.main.async {
                    self.searchResults.append(contentsOf: newBooks)
                    self.currentStartIndex += self.pageSize
                    print("📚 Added \(newBooks.count) new books (total: \(self.searchResults.count))")
                }
            } catch {
                print("❌ Decoding error: \(error)")
            }
        }.resume()
    }
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
        stopScanning()
    }
}

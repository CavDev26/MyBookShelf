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
    private var currentQuery: String = ""
    private let pageSize: Int = 20
    
    func loadMore(batchSize: Int = 30) {
        guard !isLoading else {
            return
        }
        guard loadedCount < allTitles.count else {
            return
        }
        let nextBatch = Array(allTitles.dropFirst(loadedCount).prefix(batchSize))
        loadedCount += nextBatch.count
        isLoading = true
        fetchBooksFromGoogle(titles: nextBatch)
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
    
    private func fetchBooksFromGoogle(titles: [String]) {
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
                guard let data = data else {
                    return
                }
                
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
        }
    }
    
    
    
    
    func searchBooks(query: String) {
        print("🔍 Starting new search: \(query)")
        currentQuery = query
        currentStartIndex = 0
        searchResults = []
        loadMoreSearchResults()
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
    
    
    
    
    
    
    
    
    
    
    func searchBooks2(query: String) {
        
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

// MARK: - Open Library Models
struct OpenLibrarySubjectResponse: Codable {
    let works: [OpenLibraryWork]
}

struct OpenLibraryWork: Codable {
    let title: String
}




class BookSearchViewModel: ObservableObject {
    @Published var searchResults: [BookAPI] = []
    @Published var isLoading = false
    
  
    /*func searchBooksByGenre(query: String = "", genre: String? = nil) {
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
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }*/
    

    
    /*func searchBooks(query: String) {
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
    }*/
}











final class ScannerViewModel: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var scannedCode: String?
    
    private let session = AVCaptureSession()
    private let metadataOutput = AVCaptureMetadataOutput()
    
    func startScanning() {
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
        metadataOutput.metadataObjectTypes = [.ean13, .qr] // EAN = ISBN, QR = optional

        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }    }

    func stopScanning() {
        session.stopRunning()
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

    func getSession() -> AVCaptureSession {
        return session
    }
}

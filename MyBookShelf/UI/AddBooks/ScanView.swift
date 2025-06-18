import SwiftUI
import _SwiftData_SwiftUI
import AVFoundation

struct ScanView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var scanner = ScannerViewModel()
    @EnvironmentObject var auth: AuthManager
    @Binding var searchText: String
    @State var lastSearchText: String
    @State private var scannedBook: BookAPI? = nil
    @StateObject private var viewModel = CombinedGenreSearchViewModel()
    @Environment(\.modelContext) private var context
    @State private var lastScannedISBN: String? = nil
    
    @State private var showRemoveAlert = false
    @State private var bookToRemove: SavedBook? = nil
    @Query var savedBooks: [SavedBook]


    var body: some View {
        let savedBookIDs = Set(savedBooks.map { $0.id })
        ZStack {
            ScannerPreview(scanner: scanner)
                .ignoresSafeArea()

            VStack {
                Image(systemName: "viewfinder.rectangular")
                    .resizable()
                    .scaledToFit()
                    .opacity(0.4)
                    .padding()

                Spacer()
            }
            
            
            //if !vm.isLoading {
                if let book = scannedBook {
                    VStack {
                        Spacer()
                        if !viewModel.isLoading {
                            
                            VStack(spacing: 12) {
                                if let urlString = book.coverURL, let url = URL(string: urlString) {
                                    AsyncImage(url: url) { image in
                                        image.resizable().scaledToFit()
                                    } placeholder: {
                                        Color.gray.opacity(0.3)
                                    }
                                    .frame(height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                
                                Text(book.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                Text(book.authors.joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                
                                let isSaved = savedBookIDs.contains(book.id)
                                
                                HStack(spacing: 8) {
                                    Button(action: {
                                        if !isSaved {
                                            viewModel.saveBook(book, context: context)
                                        } else {
                                            if let existing = savedBooks.first(where: { $0.id == book.id }) {
                                                bookToRemove = existing
                                                showRemoveAlert = true
                                            }
                                        }
                                    }) {
                                        addBookButtonView(isSaved: isSaved)
                                    }
                                    if let existing = savedBooks.first(where: { $0.id == book.id }) {
                                        Menu {
                                            ForEach(ReadingStatus.allCases, id: \.self) { status in
                                                Button {
                                                    withAnimation {
                                                        existing.readingStatus = status
                                                        do {
                                                            try context.save()
                                                            print("📖 Updated to \(status.rawValue)")
                                                        } catch {
                                                            print("❌ Error saving status: \(error)")
                                                        }
                                                    }
                                                } label: {
                                                    Label(status.rawValue.capitalized, systemImage: status.iconName)
                                                }
                                            }
                                        } label: {
                                            Circle()
                                                .fill(existing.readingStatus.color)
                                                .frame(width: 20, height: 20)
                                                .overlay(
                                                    Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                                )
                                                .animation(.easeInOut(duration: 0.25), value: existing.readingStatus)
                                        }
                                        .menuOrder(.fixed)
                                    }
                                }
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                            .padding()
                        } else {
                            ProgressView()
                        }
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: scannedBook)
                }
            //}


        }
        .customNavigationTitle("Looking for ISBNs...")
        .onAppear {
            scanner.restartIfNeeded()
        }
        .onDisappear {
            scanner.stopScanning()
        }
        .onChange(of: scanner.scannedCode) {
            guard let isbn = scanner.scannedCode else { return }

            if isbn == lastScannedISBN {
                print("ℹ️ ISBN già mostrato, nessuna fetch")
                return
            }

            lastScannedISBN = isbn
            fetchBookForScanner(for: isbn)
        }        .alert("Remove from Library?", isPresented: $showRemoveAlert, presenting: bookToRemove) { book in
            Button("Remove", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    context.delete(book)
                    do {
                        try context.save()
                        if !auth.uid.isEmpty {
                            FirebaseBookService.shared.deleteBook(bookID: book.id, for: auth.uid)
                        }
                        print("🗑️ Removed: \(book.title)")
                    } catch {
                        print("❌ Delete error: \(error)")
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: { book in
            Text("Are you sure you want to remove \"\(book.title)\" from your library?")
        }
    }

    
    func fetchBookForScanner(for isbn: String) {
        viewModel.searchBooks(query: "isbn:\(isbn)", reset: true) { success in
            if success, let book = viewModel.searchResults.first {
                scannedBook = book
            } else if let fallbackISBN = convertISBN13ToISBN10(isbn) {
                print("🔁 Retry with ISBN-10: \(fallbackISBN)")
                viewModel.searchBooks(query: "isbn:\(fallbackISBN)", reset: true) { fallbackSuccess in
                    if fallbackSuccess, let book = viewModel.searchResults.first {
                        scannedBook = book
                    } else {
                        print("❌ Nessun libro trovato per ISBN-13 o ISBN-10")
                        scannedBook = nil
                    }
                }
            } else {
                print("❌ Nessun libro trovato e ISBN-13 non convertibile")
                scannedBook = nil
            }
        }
    }
}


struct ScannerPreview: UIViewControllerRepresentable {
    @ObservedObject var scanner: ScannerViewModel

    func makeUIViewController(context: Context) -> ScannerPreviewController {
        let controller = ScannerPreviewController()
        controller.setup(session: scanner.getSession())
        return controller
    }

    func updateUIViewController(_ uiViewController: ScannerPreviewController, context: Context) {}
}

class ScannerPreviewController: UIViewController {
    private var previewLayer: AVCaptureVideoPreviewLayer!

    func setup(session: AVCaptureSession) {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
}

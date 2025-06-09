import SwiftUI
import AVFoundation

struct ScanView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var scanner = ScannerViewModel()
    @Binding var searchText: String
    @State var lastSearchText: String
    @State private var scannedBook: BookAPI? = nil
    @StateObject private var vm = CombinedGenreSearchViewModel()
    @Environment(\.modelContext) private var context
    @State private var lastScannedISBN: String? = nil

    var body: some View {
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

            if let book = scannedBook {
                VStack {
                    Spacer()
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
                        Text(book.authors.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Button {
                            let saved = SavedBook(from: book)
                            try? context.insert(saved)
                            try? context.save()
                            print("✅ Aggiunto libro: \(book.title)")

                            //scannedBook = nil
                        } label: {
                            Text("Aggiungi alla libreria")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.terracotta)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .padding()
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: scannedBook)
            }
        }
        .customNavigationTitle("Stai scannerizzando boss")
        .onAppear {
            scanner.restartIfNeeded()
        }
        .onDisappear {
            scanner.stopScanning()
        }
        .onChange(of: scanner.scannedCode) { code in
            guard let isbn = code else { return }

            // ✅ Evita fetch se ISBN è già mostrato
            if isbn == lastScannedISBN {
                print("ℹ️ ISBN già mostrato, nessuna fetch")
                return
            }

            lastScannedISBN = isbn
            fetchBookForScanner(for: isbn)
        }
    }

    func fetchBookForScanner(for isbn: String) {
        vm.searchBooks(query: isbn, reset: true) { success in
            if success, let book = vm.searchResults.first {
                scannedBook = book
            } else {
                print("❌ Nessun libro trovato per ISBN: \(isbn)")
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

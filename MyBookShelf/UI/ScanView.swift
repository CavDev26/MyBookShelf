import SwiftUI
import AVFoundation

struct ScanView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var scanner = ScannerViewModel()
    @Binding var searchText: String
    @State var lastSearchText: String


    var body: some View {
        ZStack {
            ScannerPreview(scanner: scanner)
                .ignoresSafeArea()

            VStack(alignment: .center) {
                
                Image(systemName: "viewfinder.rectangular")
                    .resizable()
                    .frame(width: 200, height: 80)
            }

            if let scannedCode = scanner.scannedCode {
                VStack {
                    Spacer()
                    Text("Scanned: \(scannedCode)")
                        .font(.headline)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .padding(.bottom, 40)
                }
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
            if let isbn = code {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    searchText = isbn
                    lastSearchText = ""
                    dismiss()
                }
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


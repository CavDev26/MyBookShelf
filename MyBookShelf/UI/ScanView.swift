import SwiftUI
import AVFoundation

struct ScanView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var scanner = ScannerViewModel()
    @Binding var searchText: String


    var body: some View {
        ZStack {
            ScannerPreview(scanner: scanner)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
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
        .onAppear {
            scanner.startScanning()
        }
        .onDisappear {
            scanner.stopScanning()
        }
        .onChange(of: scanner.scannedCode) { code in
            if let isbn = code {
                searchText = isbn
                dismiss()
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

#Preview {
    //ScanView()
}

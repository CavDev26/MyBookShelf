import SwiftUI
import UIKit

struct AsyncImageView: View {
    let urlString: String?
    @Environment(\.colorScheme) var colorScheme
    @State private var image: Image? = nil
    @State private var isLoading = false
    @State private var attemptedFallback = false
    
    var body: some View {
        ZStack {
            if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ZStack {
                    if colorScheme == .dark {
                        Color.gray
                            .shimmering()
                    } else {
                        Color.gray.opacity(0.3)
                            .shimmering()
                    }
                }
                .onAppear {
                    loadImage(highQuality: true)
                }
            }
        }
    }
    
    private func loadImage(highQuality: Bool) {
        guard !isLoading, let original = urlString else { return }
        
        let urlToTry: URL? = {
            if highQuality /*&& original.contains("googleusercontent.com")*/ {
                var modified = original
                if modified.contains("zoom=1") {
                    modified = modified.replacingOccurrences(of: "zoom=1", with: "zoom=10")
                }
                if !modified.contains("fife=") {
                    modified += "&fife=w800-h1200"
                }
                print("ho modificato l'url\n")
                return URL(string: modified)
            } else {
                print("NON ho modificato l'url:\n")
                return URL(string: original)
            }
        }()
        
        guard let url = urlToTry else { return }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                
                guard let data = data, let uiImage = UIImage(data: data) else {
                    if highQuality && !self.attemptedFallback {
                        self.attemptedFallback = true
                        loadImage(highQuality: false)
                    }
                    return
                }
                
                // 🔎 Check se è il placeholder
                if isPlaceholderImage(uiImage) && highQuality && !self.attemptedFallback {
                    print("sono nell'if")
                    self.attemptedFallback = true
                    loadImage(highQuality: false)
                    return
                }
                
                self.image = Image(uiImage: uiImage)
                
                
                /*if let data = data, let uiImage = UIImage(data: data) {
                 //print("\nResponse: \(response) \n Errore: \(error)\n")
                 self.image = Image(uiImage: uiImage)
                 } else if highQuality && !self.attemptedFallback {
                 // Retry con l’URL originale
                 self.attemptedFallback = true
                 print("Sto per rifre il load...")
                 loadImage(highQuality: false)
                 }*/
            }
        }.resume()
    }
    
    
    
    private func isPlaceholderImage(_ image: UIImage) -> Bool {
        guard let placeholderImage = UIImage(named: "placeholder"),
              let img1 = image.cgImage,
              let img2 = placeholderImage.cgImage,
              img1.width == img2.width,
              img1.height == img2.height else {
            return false
        }
        
        let width = img1.width
        let height = img1.height
        
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var data1 = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        var data2 = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        guard let context1 = CGContext(data: &data1,
                                       width: width,
                                       height: height,
                                       bitsPerComponent: bitsPerComponent,
                                       bytesPerRow: bytesPerRow,
                                       space: CGColorSpaceCreateDeviceRGB(),
                                       bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let context2 = CGContext(data: &data2,
                                       width: width,
                                       height: height,
                                       bitsPerComponent: bitsPerComponent,
                                       bytesPerRow: bytesPerRow,
                                       space: CGColorSpaceCreateDeviceRGB(),
                                       bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else {
            return false
        }
        
        context1.draw(img1, in: CGRect(x: 0, y: 0, width: width, height: height))
        context2.draw(img2, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return data1 == data2
    }
}


struct noBookCoverUrlView : View {
    @Environment(\.colorScheme) var colorScheme
    var width: CGFloat
    var height: CGFloat
    var bookTitle: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .dark ? Color.black.opacity(0.6) : Color.gray.opacity(0.2))
                .frame(width: width, height: height)
                .shadow(color: Color.black.opacity(0.5), radius: 4, x: 4, y: 4)
                .overlay {
                    Text(bookTitle)
                        .padding(.horizontal, width/10)
                        .minimumScaleFactor(0.5)
                        .frame(maxHeight: height/2)
                    //.lineLimit(2)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .fontDesign(.serif)
                        .multilineTextAlignment(.leading)
                }
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.clear)
                .frame(width: width*8.5/10, height: height*8.5/10)
                .border(Color.gray, width: 1)
        }
    }
}


#Preview {
    AsyncImageView(urlString: "https://covers.openlibrary.org/b/id/10521283-L.jpg")
    noBookCoverUrlView(width: 100, height: 150, bookTitle: "Il signore degli anelli")
}

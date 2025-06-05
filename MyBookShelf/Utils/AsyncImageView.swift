import SwiftUI

struct AsyncImageView: View {
    let urlString: String?
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat

    @State private var image: Image? = nil
    @State private var isLoading = false

    var body: some View {
        ZStack {
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }

    private func loadImage() {
        guard !isLoading, let urlString = urlString, let url = URL(string: urlString) else { return }
        isLoading = true

        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let uiImage = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.image = Image(uiImage: uiImage)
                self.isLoading = false
            }
        }
        task.resume()
    }
}

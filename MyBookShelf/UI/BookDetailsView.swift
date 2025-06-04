import SwiftUI
import MapKit
import UIKit
import CoreImage

struct BookDetailsView: View {
    var book: Book
    @State private var dominantColor: Color = .gray.opacity(0.2)
    @State private var titleOffset: CGFloat = .infinity
    @State private var showNavTitle = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        ZStack(alignment: .top) {
            //dominantColor.ignoresSafeArea()
            Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                .ignoresSafeArea()
            
            GeometryReader { outerGeo in
                ScrollView {
                    VStack(spacing: 0) {
                        ZStack {
                            /*RoundedRectangle(cornerRadius: 20)
                             .fill(dominantColor)
                             .frame(height: 300)
                             .animation(.easeInOut(duration: 0.3), value: dominantColor)
                             .ignoresSafeArea()*/
                            /*dominantColor
                             .frame(height: 300)
                             .animation(.easeInOut(duration: 0.3), value: dominantColor)*/
                            
                            AsyncImage(url: book.imageUrl) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width: 180, height: 230)
                                        .cornerRadius(8)
                                        .shadow(radius: 10)
                                case .failure(_):
                                    Image(systemName: "book")
                                default:
                                    ProgressView()
                                }
                            }.padding()
                        }
                        
                        
                        
                        VStack(alignment: .center, spacing: 8) {
                            Text(book.name)
                                .font(.system(size: 30, weight: .semibold, design: .serif))
                            //.foregroundColor(.white)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .onAppear {
                                                titleOffset = geo.frame(in: .global).minY
                                            }
                                            .onChange(of: geo.frame(in: .global).minY) { newVal in
                                                withAnimation(.easeInOut(duration: 0.25)) {
                                                    showNavTitle = newVal < 100
                                                }
                                            }
                                    }
                                )
                            
                            Text(book.tripDescription)
                                .font(.system(size: 20, weight: .light, design: .serif))
                                .padding(.horizontal, 8)
                            //.foregroundColor(.white)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                Text("4.2 (123)")
                                Text("• \(book.pages)")
                            }
                            .font(.caption)
                            //.foregroundColor(.white)
                        }
                        
                        HStack(spacing: 16) {
                            Button("Sample") {
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Buy for \(book.pages)") {
                            }
                            .buttonStyle(.bordered)
                        }.padding()
                        
                        Divider().padding(.vertical)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: 30, weight: .semibold, design: .serif))
                            //.foregroundColor(.white)
                                .bold()
                            ForEach(0..<10) { _ in
                                Text(book.tripDescription)
                                //.foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                    }
                    .frame(maxWidth: .infinity)
                }
                .onAppear {
                    fetchDominantColor(from: book.imageUrl) { color in
                        dominantColor = color
                    }
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .semibold))
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text(book.name)
                            .font(.system(size: 20, weight: .semibold, design: .serif))
                            .opacity(showNavTitle ? 1 : 0)
                            .animation(.easeInOut(duration: 0.25), value: showNavTitle)
                            .foregroundColor(.white)
                    }
                }
                //.toolbarBackground(Color.backgroundColorLight, for: .navigationBar)
                .toolbarBackground(dominantColor, for: .navigationBar)
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
                .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    func fetchDominantColor(from url: URL?, completion: @escaping (Color) -> Void) {
        guard let url = url else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let uiImage = UIImage(data: data) else { return }
            
            let color = uiImage.suitableBackgroundColor()
            
            DispatchQueue.main.async {
                completion(color)
            }
        }.resume()
    }
}


struct MapArea: View {
    var location: CLLocationCoordinate2D
    
    var body: some View {
        let region = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
        let cameraPosition = MapCameraPosition.region(region)
        
        Map(position: .constant(cameraPosition))
            .allowsHitTesting(false)
    }
}

struct RoundImage: View {
    var url: URL?
    
    var body: some View {
        ZStack {
            Rectangle().fill(.blue.opacity(0.2))
            AsyncImage(
                url: url,
                content: { image in image.resizable() },
                placeholder: { ProgressView().tint(.blue) }
            )
        }
        .background(.background)
        .clipShape(Circle())
        .overlay(Circle().stroke(.background, lineWidth: 6))
    }
}

#Preview {
    MyBooksView2().modelContainer(PreviewData.makeModelContainer())
}


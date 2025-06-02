import MapKit
import SwiftUI

struct BookDetailsView: View {
    var book: Book
    
    var body: some View {
        ScrollView {
            VStack {
                MapArea(
                    location: CLLocationCoordinate2D(
                        latitude: book.latitude, longitude: book.longitude)
                )
                .frame(height: 280)
                RoundImage(url: book.imageUrl)
                    .frame(width: UIScreen.main.bounds.width, height: 120)
                    .offset(y: -68)
                    .padding(.bottom, -68)
                
                
                VStack(alignment: .center) {
                    Text(book.name).font(.title)
                    Text(DateFormatter().string(from: book.date)).font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center).padding()
                
                Divider()
                
                VStack {
                    Text("Description").font(.title2).frame(
                        maxWidth: .infinity, alignment: .leading)
                    Spacer().frame(height: 8)
                    Text(book.tripDescription).frame(
                        maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .frame(width: UIScreen.main.bounds.width)
            .ignoresSafeArea(edges: .top)
            .navigationTitle(book.name)
            .navigationBarTitleDisplayMode(.inline)
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
}

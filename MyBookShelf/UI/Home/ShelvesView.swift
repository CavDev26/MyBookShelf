import SwiftUICore
import _MapKit_SwiftUI
import SwiftUI

struct ShelvesView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var permissionManager: PermissionManager // 👈
    
    var shelves: [Shelf]
    @ObservedObject var viewModel: CombinedGenreSearchViewModel
    @State private var showFullMap = false
    @State var showShelfSheet: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                .ignoresSafeArea()

            ScrollView {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 16) {
                    ForEach(shelves) { shelf in
                        NavigationLink(destination: ShelfView(shelf: shelf, viewModel: viewModel)) {
                            VStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.terracotta)
                                    .frame(height: 100)
                                    .overlay(
                                        Image(systemName: "books.vertical")
                                            .foregroundColor(.white)
                                    )
                                Text(shelf.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()

                Button {
                    showFullMap.toggle()
                } label: {
                    MapView(
                        shelves: shelves,
                        userLocation: permissionManager.isLocationAuthorized ? permissionManager.locationManager.location?.coordinate : nil
                    )
                    .frame(height: 200)
                    .cornerRadius(12)
                    .padding()
                }
            }
        }
        .customNavigationTitle("Shelves")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showShelfSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            if !permissionManager.isLocationAuthorized {
                permissionManager.requestLocationPermission()
            }
        }
        .fullScreenCover(isPresented: $showFullMap) {
            FullMapView(
                shelves: shelves,
                userLocation: permissionManager.isLocationAuthorized ? permissionManager.locationManager.location?.coordinate : nil,
                dismiss: { showFullMap = false }
            )
        }
        .sheet(isPresented: $showShelfSheet) {
            addShelfSheetView()
                .presentationDetents([.fraction(0.8)])
                .presentationDragIndicator(.visible)
        }
    }
}

struct ShelfMapAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let name: String
    let address: String?
}

struct MapView: View {
    var shelves: [Shelf]
    var userLocation: CLLocationCoordinate2D?
    
    var annotations: [ShelfMapAnnotation] {
        shelves.compactMap {
            guard let lat = $0.latitude, let lon = $0.longitude else { return nil }
            return ShelfMapAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                name: $0.name,
                address: $0.address
            )        }
    }
    
    var body: some View {
        Map(coordinateRegion: .constant(defaultRegion), annotationItems: annotations) { item in
            MapMarker(coordinate: item.coordinate, tint: .red)
        }
    }
    
    private var defaultRegion: MKCoordinateRegion {
        if let loc = userLocation {
            return MKCoordinateRegion(center: loc, span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2))
        } else {
            return MKCoordinateRegion(center: .init(latitude: 0, longitude: 0), span: .init(latitudeDelta: 50, longitudeDelta: 50))
        }
    }
}
struct FullMapView: View {
    var shelves: [Shelf]
    var userLocation: CLLocationCoordinate2D?
    var dismiss: () -> Void
    
    @State private var region: MKCoordinateRegion = .init()
    @State private var selectedAnnotationID: UUID? = nil
    
    private var annotations: [ShelfMapAnnotation]
    
    init(shelves: [Shelf], userLocation: CLLocationCoordinate2D?, dismiss: @escaping () -> Void) {
        self.shelves = shelves
        self.userLocation = userLocation
        self.dismiss = dismiss
        self.annotations = shelves.compactMap { shelf in
            guard let lat = shelf.latitude, let lon = shelf.longitude else { return nil }
            return ShelfMapAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                name: shelf.name,
                address: shelf.address
            )
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: annotations) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    VStack(spacing: 4) {
                        if selectedAnnotationID == annotation.id {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(annotation.name)
                                    .font(.headline)
                                Text(annotation.address ?? "Coordinates")
                                    .font(.caption)
                                HStack {
                                    Button {
                                        let destination = annotation.coordinate
                                        let url = URL(string: "http://maps.apple.com/?daddr=\(destination.latitude),\(destination.longitude)")!
                                        UIApplication.shared.open(url)
                                    } label: {
                                        Image(systemName: "car.fill")
                                            .padding(6)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .transition(.scale)
                        }

                        Image(systemName: "mappin.and.ellipse")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.red)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedAnnotationID = (selectedAnnotationID == annotation.id) ? nil : annotation.id
                                }
                            }
                    }
                    .animation(.easeInOut, value: selectedAnnotationID)
                    .offset(y: selectedAnnotationID == annotation.id ? -40 : 0)
                    .zIndex(selectedAnnotationID == annotation.id ? 1 : 0)
                }
            }
            .onAppear {
                if let loc = userLocation {
                    region = MKCoordinateRegion(center: loc, span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1))
                }
            }
            
            Button(action: dismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    //.background(Color.black.opacity(0.6))
                    .clipShape(Circle())
                    .padding()
            }
            .padding(.top, 20)

        }
        .ignoresSafeArea()
    }
}

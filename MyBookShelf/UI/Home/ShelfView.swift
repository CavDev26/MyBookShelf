import SwiftUICore
import _SwiftData_SwiftUI
import SwiftUI
import MapKit
import CoreLocation

struct ShelfView: View {
    var shelf: Shelf
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAllBooks: Bool = false
    @State var showAddBookShelfSheet: Bool = false
    @State var showModDesc: Bool = false
    @State var manageShelfSheet: Bool = false
    @ObservedObject var viewModel: CombinedGenreSearchViewModel
    @EnvironmentObject var auth: AuthManager
    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    
    @State var showRemoveAlert : Bool = false
    
    private var books: [SavedBook] {
        shelf.books
    }
    
    /*private var mapRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: shelf.latitude ?? 0,
                longitude: shelf.longitude ?? 0
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // circa 10km
        )
    }*/
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Sezione libri
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.terracotta)
                            .frame(width: 4, height: 20)
                        
                        Text("Books in this shelf")
                            .font(.system(size: 20, weight: .semibold, design: .serif))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    if !books.isEmpty {
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                            if showAllBooks {
                                ForEach(books) { book in
                                    NavigationLink(
                                        destination: BookDetailsView(book: book, viewModel: viewModel)
                                    ) {
                                        BookListItemGrid(book: book, showStatus: false)
                                            .aspectRatio(2/3, contentMode: .fill)
                                            .padding(4)
                                    }
                                }
                            } else {
                                ForEach(books.prefix(6), id: \.self) { book in
                                    NavigationLink(
                                        destination: BookDetailsView(book: book, viewModel: viewModel)
                                    ) {
                                        BookListItemGrid(book: book, showStatus: false)
                                            .aspectRatio(2/3, contentMode: .fill)
                                            .padding(4)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if books.count > 6 {
                            Button(action: { showAllBooks.toggle() }) {
                                Text(showAllBooks ? "Show Less" : "Show More")
                                    .font(.subheadline)
                                    .padding(.horizontal)
                                    .foregroundColor(Color.terracotta)
                            }
                        }
                    } else { //no books
                        Text("No books.\nYou can add them by tapping the plus button in the top right corner.")
                            .padding(.leading)
                            .padding(.trailing)
                            .multilineTextAlignment(.leading)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.terracotta)
                            .frame(width: 4, height: 20)
                        
                        Text("Description")
                            .font(.system(size: 20, weight: .semibold, design: .serif))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "pencil")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .onTapGesture {
                                showModDesc.toggle()
                            }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    VStack {
                        if let desc = shelf.shelfDescription, !desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(desc)
                                .font(.body)
                                .foregroundColor(.secondary)
                        } else {
                            Text("No description available")
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    
                    // Mappa
                    if let lat = shelf.latitude, let lon = shelf.longitude {
                        Map(coordinateRegion: $mapRegion, annotationItems: [shelf]) { _ in                            MapMarker(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), tint: .red)
                        }
                        .frame(height: 250)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    VStack(alignment: .center){
                        Button {
                            manageShelfSheet.toggle()
                        } label: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(colorScheme != .dark ? Color.terracotta.opacity(0.8) : Color.terracottaDarkIcons)
                                .frame(width: 140, height: 60)
                                .overlay{
                                    Text("Manage Shelf")
                                        .minimumScaleFactor(0.7)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 40)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.top)
            }
        }
        .customNavigationTitle(shelf.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddBookShelfSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showModDesc) {
            ModShelfDescriptionSheet(shelf: shelf, auth: auth)
                .presentationDetents([.fraction(0.4)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAddBookShelfSheet) {
            AddBooksToShelfSheet(auth: auth, shelf: shelf)
        }
        .sheet(isPresented: $manageShelfSheet) {
            ManageShelfSheet(shelf: shelf, showRemoveAlert: $showRemoveAlert, auth: auth)
                .presentationDetents([.fraction(0.6)])
                .presentationDragIndicator(.visible)
        }
        .alert("Remove Shelf?", isPresented: $showRemoveAlert, presenting: shelf) { shelf in
            Button("Remove", role: .destructive) {
                withAnimation {
                    shelf.needsSync = true
                    ShelfService.shared.deleteShelf(shelf, context: context, userID: auth.uid) { result in
                        switch result {
                        case .success():
                            print("✅ Removed from Firebase")
                        case .failure(let error):
                            print("⚠️ Remove failed: \(error.localizedDescription)")
                        }
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: { shelf in
            Text("Are you sure you want to remove \"\(shelf.name)\" Shelf?")
        }
        .onAppear {
            if let lat = shelf.latitude, let lon = shelf.longitude {
                mapRegion = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
            }
        }
        .onChange(of: shelf.latitude) { newLat in
            updateMapRegion()
        }
        .onChange(of: shelf.longitude) { newLon in
            updateMapRegion()
        }
    }
    func updateMapRegion() {
        if let lat = shelf.latitude, let lon = shelf.longitude {
            mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        }
    }
}

struct ManageShelfSheet: View {
    var shelf : Shelf
    @Binding var showRemoveAlert : Bool
    @ObservedObject var auth: AuthManager
    @State private var name: String = ""
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var address: String = ""
    @State private var latitude: Double?
    @State private var longitude: Double?
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 16) {
                Group {
                    Text("Edit Shelf name")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("Name", text: $name)
                        .padding(10)
                        .background(Color.gray.opacity(colorScheme == .dark ? 0.2 : 0.2))
                        .cornerRadius(8)

                    Text("Edit Address")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("Address", text: $address)
                        .padding(10)
                        .background(Color.gray.opacity(colorScheme == .dark ? 0.2 : 0.2))
                        .cornerRadius(8)

                    Text("Coordinates")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack {
                        TextField("Latitude", value: $latitude, format: .number)
                            .keyboardType(.decimalPad)
                        TextField("Longitude", value: $longitude, format: .number)
                            .keyboardType(.decimalPad)
                    }
                    .padding(10)
                    .background(Color.gray.opacity(colorScheme == .dark ? 0.2 : 0.2))
                    .cornerRadius(8)
                }
                .padding(.horizontal)

                Spacer()

                Button {
                    showRemoveAlert.toggle()
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red.opacity(0.8))
                        .frame(width: 140, height: 50)
                        .overlay {
                            Text("Delete Shelf")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                }
            }
            .padding(.top)
            .navigationTitle("Manage Shelf")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save") {
                        shelf.name = name
                        shelf.address = address
                        
                        if !address.isEmpty {
                            let geocoder = CLGeocoder()
                            geocoder.geocodeAddressString(address) { placemarks, error in
                                if let error = error {
                                    print("❌ Geocoding error: \(error.localizedDescription)")
                                }

                                if let location = placemarks?.first?.location {
                                    shelf.latitude = location.coordinate.latitude
                                    shelf.longitude = location.coordinate.longitude
                                    print("📍 Location found: \(location.coordinate)")
                                }

                                // salva comunque, con o senza coordinate
                                finishSavingShelf()
                            }
                        } else {
                            shelf.latitude = latitude
                            shelf.longitude = longitude
                            finishSavingShelf()
                        }
                    }
                }
            }
            .onAppear{
                name = shelf.name
                address = shelf.address ?? ""
                latitude = shelf.latitude
                longitude = shelf.longitude
            }
        }
    }
    func finishSavingShelf() {
        shelf.needsSync = true
        ShelfService.shared.saveShelf(shelf, context: context, userID: auth.uid) { result in
            switch result {
            case .success():
                print("✅ Uploaded to Firebase")
            case .failure(let error):
                print("⚠️ Upload failed: \(error.localizedDescription)")
            }
            dismiss()
        }
    }
}

struct ModShelfDescriptionSheet: View {
    var shelf : Shelf
    @State private var description: String = ""
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var auth: AuthManager
    
    var body: some View {
        NavigationStack{
            VStack{
                /*Text("Edit description")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)*/
                TextField("Description", text: $description)
                    .padding(10)
                    .background(Color.gray.opacity(colorScheme == .dark ? 0.2 : 0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            .padding(.top)
            .navigationTitle("Edit Description")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save") {
                        shelf.shelfDescription = description
                        shelf.needsSync = true
                        ShelfService.shared.saveShelf(shelf, context: context, userID: auth.uid) { result in
                            switch result {
                            case .success():
                                print("✅ Uploaded to Firebase")
                            case .failure(let error):
                                print("⚠️ Upload failed: \(error.localizedDescription)")
                            }
                            dismiss()
                        }
                    }
                    //.disabled()
                }
            }
        }
        
    }
}



struct AddBooksToShelfSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \SavedBook.title) var allBooks: [SavedBook]
    @ObservedObject var auth: AuthManager
    
    var shelf: Shelf
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(allBooks) { book in
                    HStack {
                        if let urlString = book.coverURL {
                            AsyncImageView(urlString: urlString)
                                .frame(width: 40, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            noBookCoverUrlView(width: 40, height: 60, bookTitle: book.title)
                        }
                        VStack(alignment: .leading) {
                            Text(book.title)
                                .font(.headline)
                                .lineLimit(1)
                            if let author = book.authors.first {
                                Text(author)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Button {
                            if shelf.books.contains(book) {
                                shelf.books.removeAll { $0.id == book.id }
                            } else {
                                shelf.books.append(book)
                            }
                        } label: {
                            Image(systemName: shelf.books.contains(book) ? "checkmark.circle.fill" : "plus.circle")
                                .foregroundColor(shelf.books.contains(book) ? Color.terracotta : .gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Add Books to this shelf")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        shelf.needsSync = true
                        ShelfService.shared.saveShelf(shelf, context: context, userID: auth.uid) { result in
                            switch result {
                            case .success():
                                print("✅ Uploaded to Firebase")
                            case .failure(let error):
                                print("⚠️ Upload failed: \(error.localizedDescription)")
                            }
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

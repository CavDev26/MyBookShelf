import SwiftUI
import MapKit
import _SwiftData_SwiftUI
import CoreLocation


struct HomeView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var context
    @EnvironmentObject var auth: AuthManager
    @State var showShelfSheet: Bool = false
    @StateObject private var viewModel = CombinedGenreSearchViewModel()
    
    let columnCount: Int = 3
    let gridSpacing: CGFloat = 20.0
    @Query(sort: \SavedBook.title, order: .forward) var books: [SavedBook]
    @Binding var selectedTab: Int
    @Query(sort: \Shelf.name) var shelves: [Shelf] // 👈 carica automaticamente le scaffalature

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                    .ignoresSafeArea()
                VStack{
                    ZStack(alignment: .top) {
                        TopNavBar {
                            Image("MyIcon").resizable().frame(width: 50, height:50)
                            Text("MyBookShelf")
                                .padding(.leading, -10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.custom("Baskerville-SemiBoldItalic", size: 20))
                        }
                    }
                    ScrollView(.vertical, showsIndicators: false) {
                        yourProgressView(books: books, gridSpacing: gridSpacing, columnCount: columnCount, selectedTab: $selectedTab, viewModel: viewModel)
                        challengesPreview()
                        yourShelvesView(shelves: shelves, showShelfSheet: $showShelfSheet, viewModel: viewModel)
                    }
                }
            }
            .sheet(isPresented: $showShelfSheet) {
                addShelfSheetView()
                    .presentationDetents([.fraction(0.8)])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear{
            if !auth.uid.isEmpty {
                FirebaseBookService.shared.syncBooksToLocal(for: auth.uid, context: context)
            }
        }
    }
}





struct yourShelvesView: View {
    @Environment(\.colorScheme) var colorScheme
    var shelves: [Shelf]
    @Binding var showShelfSheet: Bool
    @ObservedObject var viewModel: CombinedGenreSearchViewModel


    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.terracotta)
                .frame(width: 4, height: 20)
            
            Text("Your Shelves")
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
        .padding(.top)
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(shelves) { shelf in
                        NavigationLink(destination: ShelfView(shelf: shelf, viewModel: viewModel)) {
                            VStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.terracotta)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "books.vertical")
                                            .foregroundColor(.white)
                                    )
                                Text(shelf.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    Button {
                        showShelfSheet.toggle()
                    } label: {
                        VStack{
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.terracotta)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                )
                            Text("Add Shelf")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight.opacity(0.8))
        )
        .padding(.horizontal, 8)
        .padding(.bottom, 10)
    }
}

struct challengesPreview: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationLink(destination: ChallengesView()
        ) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.terracotta)
                    .frame(width: 4, height: 20)
                
                Text("Challenges & Achievements")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding(.horizontal)
            .padding(.top)
        }
        
        HStack(spacing: 16) {
            NavigationLink(destination: ChallengesView()) {
                VStack(spacing: 4) {
                    SingleRingProgress(progress: 0.75, current: 18, goal: 24, small: true)
                        .padding()
                    Text("2025 Goal")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            NavigationLink(destination: ChallengesView()) {
                VStack(spacing: 4) {
                    SingleRingProgress(progress: 0.33, current: 1, goal: 3, small: true)
                        .padding()
                    Text("June Goal")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            NavigationLink(destination: StatsView()) {
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                            .frame(width: 60, height: 60)
                        Circle()
                            .trim(from: 0, to: 1.0)
                            .stroke(Color.terracotta, lineWidth: 10)
                            .frame(width: 60, height: 60)
                            .opacity(0.2)
                        
                        Image(systemName: "chart.bar.xaxis")
                            .foregroundColor(.terracotta)
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .padding()
                    Text("Stats")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                //.padding()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight.opacity(0.8))
        )
        .padding(.horizontal, 8)
        .padding(.bottom, 10)
    }
}


struct yourProgressView: View {
    var books: [SavedBook]
    var gridSpacing: CGFloat
    var columnCount: Int
    @Binding var selectedTab: Int
    @ObservedObject var viewModel: CombinedGenreSearchViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.terracotta)
                .frame(width: 4, height: 20)
            
            Text("Your Progress")
                .font(.system(size: 20, weight: .semibold, design: .serif))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top)
        .padding(.leading)
        VStack{
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: gridSpacing), count: columnCount), spacing: gridSpacing) {
                
                ForEach(books) { book in
                    if (book.readingStatus == .reading) {
                        VStack {
                            
                            
                            
                            NavigationLink(
                                destination: BookDetailsView(book: book, viewModel: viewModel)
                            ) {
                                BookListItemGrid(book: book, showStatus: true)
                                    .aspectRatio(2/3, contentMode: .fill)
                            }
                            
                            
                            progressViewBook(book: book, viewModel: viewModel)
                                .padding(.top, -10)
                        }
                    }
                }
                if books.count(where: { $0.readingStatus == .reading }) < 3 {
                    BlankBookPlaceHolderView(selectedTab: $selectedTab)
                        .aspectRatio(2/4, contentMode: .fill)
                }            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight.opacity(0.8))
        )
        .padding(.horizontal, 8)
        .padding(.bottom, 10)
    }
}

struct progressViewBook: View {
    @State var size: CGSize = .zero
    var book: SavedBook
    @ObservedObject var viewModel: CombinedGenreSearchViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    var progress: CGFloat {
        guard let pageCount = book.pageCount, pageCount > 0 else { return 0 }
        return CGFloat(book.pagesRead) / CGFloat(pageCount)
    }
    
    var body: some View {
        
        NavigationLink (
            destination: BookDetailsView(book: book, openSheetOnAppear: true, viewModel: viewModel)) {
                
                VStack(alignment: .leading, spacing: 6) {
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(colorScheme == .dark ? Color.white.opacity(0.2) : Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .saveSize(in: $size)
                        
                        Capsule()
                            .fill(Color.terracottaDarkIcons)
                            .frame(width: progress * size.width, height: 8)
                            .animation(.easeInOut(duration: 0.5), value: book.pagesRead)
                        
                    }.padding(.top)
                    
                    
                    HStack {
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.terracotta)
                            .overlay {
                                Text("Update")
                                    .font(.system(size: 12, weight: .semibold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .foregroundColor(Color.secondary)
                                    .padding(4)
                            }
                    }
                }
            }
    }
}














struct addShelfSheetView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isAddressFieldFocused: Bool
    @Environment(\.colorScheme) var colorScheme

    @State private var address: String = ""
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var latitude: Double? = nil
    @State private var longitude: Double? = nil

    @StateObject private var completerDelegate = CompleterDelegate()
    private var searchCompleter = MKLocalSearchCompleter()
    private var canSubmit: Bool { !name.isEmpty }
    @State private var locationService = LocationService()

    var body: some View {
            NavigationStack {
                ZStack {
                    if colorScheme == .dark {
                        Color.backgroundColorDark2.ignoresSafeArea()
                    } else {
                        Color.lightColorApp.ignoresSafeArea()
                    }
                    Form {
                        Section(
                            content: {
                                TextField("Name", text: $name)
                            },
                            header: { Text("Name") }
                        )
                        Section(
                            content: {
                                TextField("Description", text: $description)
                            },
                            header: { Text("Description") }
                        )
                        
                        
                        Section(header: Text("Address (optional)")) {
                            TextField("Enter address", text: $address)
                                .focused($isAddressFieldFocused)
                                .onChange(of: address) { newValue in
                                    print("🔍 Querying: \(newValue)")
                                    searchCompleter.queryFragment = newValue
                                }
                            
                            if !completerDelegate.suggestions.isEmpty {
                                List(completerDelegate.suggestions, id: \.self) { suggestion in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(suggestion.title)
                                                .font(.subheadline)
                                            if !suggestion.subtitle.isEmpty {
                                                Text(suggestion.subtitle)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 4)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        let fullAddress = suggestion.title + ", " + suggestion.subtitle
                                        address = fullAddress
                                        resolveCoordinates(for: suggestion)
                                        isAddressFieldFocused = false // chiude tastiera
                                        
                                        // ❗️Posticipa l'azzeramento per farlo dopo l'autocompletamento
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            withAnimation {
                                                completerDelegate.suggestions = []
                                            }
                                            searchCompleter.queryFragment = ""
                                        }
                                    }
                                }
                                .listRowInsets(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                            }
                        }
                        
                        
                        
                        
                        
                        Section(
                            content: {
                                TextField("Latitude", value: $latitude, format: .number)
                                    .keyboardType(.numberPad)
                                    .onChange(of: locationService.latitude) {
                                        latitude = locationService.latitude
                                    }
                                TextField(
                                    "Longitude", value: $longitude, format: .number
                                )
                                .keyboardType(.numberPad)
                                .onChange(of: locationService.longitude) {
                                    longitude = locationService.longitude
                                }
                                
                                HStack {
                                    Button(action: { locationService.requestLocation() }
                                    ) {
                                        Text("Get current location")
                                    }
                                    if locationService.isMonitoring {
                                        Spacer()
                                        ProgressView().tint(.blue)
                                    }
                                }
                            },
                            header: { Text("Coordinates") }
                        )
                    }
                    .scrollContentBackground(.hidden) // 👈 Nasconde sfondo originale del Form
                }     
                .navigationTitle("Add Shelf")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button("Save") {
                            if !canSubmit { return }
                            let shelf = Shelf(
                                name: name,
                                latitude: latitude ?? 0,
                                longitude: longitude ?? 0,
                                shelfDescription: description ?? "",
                                address: address.isEmpty ? nil : address
                            )
                            context.insert(shelf)
                            do {
                                try context.save()
                                print("✅ Saved: \(shelf.name)")
                                /*if let uid = Auth.auth().currentUser?.uid {
                                    let firestoreBook = FirebaseBookMapper.toFirestore(saved)
                                    FirebaseBookService.shared.upload(book: firestoreBook, for: uid)
                                }*/
                            } catch {
                                print("❌ Save error: \(error)")
                            }
                            dismiss()
                        }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                .onAppear {
                    searchCompleter.resultTypes = .address
                    searchCompleter.delegate = completerDelegate
                    completerDelegate.onUpdate = { results in
                        print("✅ Received \(results.count) suggestions")
                        completerDelegate.suggestions = results
                    }
                }
                .onChange(of: locationService.latitude) { lat in
                    if let lat, let lon = locationService.longitude {
                        latitude = lat
                        longitude = lon
                        print("📍 Location set: \(lat), \(lon)")
                    }
                }
        }
    }
    private func resolveCoordinates(for suggestion: MKLocalSearchCompletion) {
        let req = MKLocalSearch.Request(completion: suggestion)
        MKLocalSearch(request: req).start { response, err in
            if let coordinate = response?.mapItems.first?.placemark.coordinate {
                latitude = coordinate.latitude
                longitude = coordinate.longitude
                print("📦 Resolved coords: \(coordinate.latitude), \(coordinate.longitude)")
            } else {
                print("❌ Resolve error: \(err?.localizedDescription ?? "Unknown")")
            }
        }
    }
}
// Delegato per il searchCompleter
class CompleterDelegate: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var suggestions: [MKLocalSearchCompletion] = []
    var onUpdate: (([MKLocalSearchCompletion]) -> Void)?

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        onUpdate?(completer.results)
    }
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("❌ Completer error: \(error.localizedDescription)")
    }
}

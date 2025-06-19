

import SwiftUI

struct manualAddSheet: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var selectedImage: UIImage? = nil
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingURLPrompt = false
    @State private var coverURLFromUser: String = ""
    @State private var showingSourceDialog = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @EnvironmentObject var auth: AuthManager // per UID Firebase
    @ObservedObject var viewModel: CombinedGenreSearchViewModel
    
    
    @State private var isSaving = false
    @State private var showSavedCheckmark = false
    
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var publisher: String = ""
    @State private var publishedDate: String = ""
    @State private var description: String = ""
    @State private var pageCount: String = ""
    @State private var readingStatus: ReadingStatus = .unread
    @State private var rating: Double = 0
    @State private var selectedGenres: Set<BookGenre> = []
    @State private var showAllGenres = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Cover Placeholder
                    Button {
                        showingSourceDialog = true
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 160, height: 240)
                            
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 160, height: 240)
                                    .clipped()
                                    .cornerRadius(8)
                            } else {
                                Text("Tap to add cover")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .confirmationDialog("Choose Image Source", isPresented: $showingSourceDialog, titleVisibility: .visible) {
                        Button("Photo Library") { showingImagePicker = true }
                        Button("Camera") { showingCamera = true }
                        Button("From URL") { showingURLPrompt = true }
                        Button("Cancel", role: .cancel) { }
                    }
                    // Title
                    TextField("Title", text: $title)
                        .textFieldStyle(.roundedBorder)
                    
                    // Author
                    TextField("Author", text: $author)
                        .textFieldStyle(.roundedBorder)
                    
                    // Publisher
                    TextField("Publisher", text: $publisher)
                        .textFieldStyle(.roundedBorder)
                    
                    // Published Date
                    TextField("Published Date", text: $publishedDate)
                        .textFieldStyle(.roundedBorder)
                    
                    // Reading Status and Rating
                    HStack {
                        Menu {
                            ForEach(ReadingStatus.assignableCases, id: \.self) { status in
                                Button(status.rawValue.capitalized) {
                                    readingStatus = status
                                }
                            }
                        } label: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(readingStatus.color)
                                .frame(height: 40)
                                .overlay(
                                    Text(readingStatus.rawValue.capitalized)
                                        .foregroundColor(.secondary)
                                )
                        }
                        
                        Spacer()
                        
                        RatingViewEditable(rating: $rating)
                    }
                    
                    // Page Count
                    TextField("Page Count", text: $pageCount)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    
                    // Description
                    TextField("Description", text: $description, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(4...6)
                    
                    // Genre Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Genres")
                            .font(.headline)
                        
                        let displayedGenres = BookGenre.allCases.filter { $0 != .all }
                        let genresToShow = showAllGenres ? displayedGenres : Array(displayedGenres.prefix(6))
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(genresToShow, id: \.self) { genre in
                                Button(action: {
                                    if selectedGenres.contains(genre) {
                                        selectedGenres.remove(genre)
                                    } else {
                                        selectedGenres.insert(genre)
                                    }
                                }) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedGenres.contains(genre) ? Color.terracotta : Color.gray.opacity(0.2))
                                        .overlay{
                                            Text(genre.rawValue)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                                .foregroundColor(.primary)
                                                .padding()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 40)
                                        .padding(.vertical, 8)
                                }
                            }
                        }
                        
                        if !showAllGenres {
                            Button("Show All Genres") {
                                withAnimation {
                                    showAllGenres = true
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.top, 4)
                        }
                    }
                    
                }
                .padding()
            }
            .navigationTitle("Add Book Manually")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
            }
            .fullScreenCover(isPresented: $showingCamera) {
                ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
                    .preferredColorScheme(.dark) // 👈 Forza dark mode solo qui
            }
            .alert("Insert Image URL", isPresented: $showingURLPrompt, actions: {
                TextField("Image URL", text: $coverURLFromUser)
                Button("Load") {
                    loadImageFromURL()
                }
                Button("Cancel", role: .cancel) { }
            })
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // Dismiss sheet
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else if showSavedCheckmark {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Button("Save") {
                            saveManualBook()
                        }
                    }
                }
            }
        }
    }
    
    func saveManualBook() {
        guard !title.isEmpty else { return }
        
        isSaving = true
        
        // Crea ID univoco
        let newID = UUID().uuidString
        
        // Crea nuovo SavedBook
        var saved = SavedBook(
            id: newID,
            title: title,
            authors: [author],
            publisher: publisher,
            coverURL: coverURLFromUser.isEmpty ? nil : coverURLFromUser,
            pageCount: Int(pageCount),
            bookDescription: description,
            publishedDate: publishedDate,
            industryIdentifiers: [],
            categories: selectedGenres.map(\.rawValue),
            mainCategory: selectedGenres.first?.rawValue,
            averageRating: rating,
            ratingsCount: nil,
            readingStatus: readingStatus, pagesRead: 0, userNotes: "", rating: Int(rating), favourite: false,
            genres: Array(selectedGenres),
            coverJPG: selectedImage?.jpegData(compressionQuality: 0.8) // 👈
        )
        viewModel.saveBook(saved, context: context)
        withAnimation {
            showSavedCheckmark = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dismiss()
        }
        isSaving = false
    }
    
    
    func loadImageFromURL() {
        guard let url = URL(string: coverURLFromUser),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else { return }
        
        selectedImage = image
    }
}
struct RatingViewEditable: View {
    @Binding var rating: Double
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: rating >= Double(index) ? "star.fill" : (rating >= Double(index) - 0.5 ? "star.lefthalf.fill" : "star"))
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.terracotta)
                    .onTapGesture {
                        if rating == Double(index) {
                            rating = Double(index) - 0.5
                        } else {
                            rating = Double(index)
                        }
                    }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        picker.modalPresentationStyle = .fullScreen // 👈 questo è fondamentale
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

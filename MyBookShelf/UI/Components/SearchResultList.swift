import SwiftUI
import _SwiftData_SwiftUI

struct SearchResultList: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showRemoveAlert = false
    @State private var bookToRemove: SavedBook? = nil
    
    @ObservedObject var viewModel: CombinedGenreSearchViewModel
    
    var books: [BookAPI]
    @Query var savedBooks: [SavedBook]
    
    var savedBookIDs: Set<String> {
        Set(savedBooks.map { $0.id })
    }
    
    
    var body: some View {
        //let savedBookIDs = Set(savedBooks.map { $0.id })
        
        NavigationStack {
            VStack(spacing: 12) {
                ForEach(books) { book in
                    let isSaved = savedBookIDs.contains(book.id)
                    NavigationLink {
                        BookDetailsView(book: book, viewModel: viewModel)
                    } label: {
                        BookRowView(
                            book: book,
                            isSaved: isSaved,
                            savedBook: savedBooks.first(where: { $0.id == book.id }),
                            onSaveTapped: {
                                if !isSaved {
                                    viewModel.saveBook(book, context: context)
                                } else {
                                    if let existing = savedBooks.first(where: { $0.id == book.id }) {
                                        bookToRemove = existing
                                        showRemoveAlert = true
                                    }
                                }
                            }
                            
                            
                            /*onSaveTapped: {
                                if !isSaved {
                                    /*let saved = SavedBook(from: book)
                                    context.insert(saved)
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        DispatchQueue.main.async {
                                            do {
                                                try context.save()
                                                print("✅ Saved: \(saved.title)")
                                            } catch {
                                                print("❌ Save error: \(error)")
                                            }
                                        }
                                    }*/
                                } else {
                                    if let existing = savedBooks.first(where: { $0.id == book.id }) {
                                        bookToRemove = existing
                                        showRemoveAlert = true
                                    }
                                }
                            }*/,
                            onDeleteTapped: {
                                if let book = bookToRemove {
                                    context.delete(book)
                                    do {
                                        try context.save()
                                        print("🗑️ Removed: \(book.title)")
                                    } catch {
                                        print("❌ Delete error: \(error)")
                                    }
                                }
                            },
                            onStatusChange: { status in
                                if let existing = savedBooks.first(where: { $0.id == book.id }) {
                                    withAnimation {
                                        existing.readingStatus = status
                                        do {
                                            try context.save()
                                            print("📖 Updated to \(status.rawValue)")
                                        } catch {
                                            print("❌ Error saving status: \(error)")
                                        }
                                    }
                                }
                            }
                        )
                        
                        
                        
                        
                        
                        
                        /*HStack(alignment: .top, spacing: 12) {
                         if let urlString = book.coverURL {
                         AsyncImageView(urlString: urlString)
                         .frame(width: 60, height: 100)
                         .clipShape(RoundedRectangle(cornerRadius: 8))
                         } else {
                         noBookCoverUrlView()
                         }
                         
                         VStack(alignment: .leading, spacing: 6) {
                         Text(book.title)
                         .font(.system(size: 16, weight: .semibold))
                         .foregroundColor(.primary)
                         .lineLimit(1)
                         
                         Text(book.authors.joined(separator: ", "))
                         .font(.system(size: 13))
                         .foregroundColor(.secondary)
                         .lineLimit(1)
                         
                         Text(book.publisher == "Unknown" ? " " : book.publisher)
                         .font(.system(size: 13))
                         .foregroundColor(.secondary)
                         .lineLimit(1)
                         
                         let isSaved = savedBookIDs.contains(book.id)
                         
                         HStack(spacing: 8) {
                         Button(action: {
                         if !isSaved {
                         let saved = SavedBook(from: book)
                         context.insert(saved)
                         withAnimation(.easeInOut(duration: 0.3)) {
                         DispatchQueue.main.async {
                         do {
                         try context.save()
                         print("✅ Saved: \(saved.title)")
                         } catch {
                         print("❌ Save error: \(error)")
                         }
                         }
                         }
                         } else {
                         if let existing = savedBooks.first(where: { $0.id == book.id }) {
                         bookToRemove = existing
                         showRemoveAlert = true
                         }
                         }
                         }) {
                         addBookButtonView(isSaved: isSaved)
                         }
                         if let existing = savedBooks.first(where: { $0.id == book.id }) {
                         Menu {
                         ForEach(ReadingStatus.allCases, id: \.self) { status in
                         Button {
                         withAnimation {
                         existing.readingStatus = status
                         do {
                         try context.save()
                         print("📖 Updated to \(status.rawValue)")
                         } catch {
                         print("❌ Error saving status: \(error)")
                         }
                         }
                         } label: {
                         Label(status.rawValue.capitalized, systemImage: status.iconName)
                         }
                         }
                         } label: {
                         Circle()
                         .fill(existing.readingStatus.color)
                         .frame(width: 20, height: 20)
                         .overlay(
                         Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1)
                         )
                         .animation(.easeInOut(duration: 0.25), value: existing.readingStatus)
                         }
                         .menuOrder(.fixed)
                         }
                         }
                         }
                         .padding(.top, 4)
                         }//da commentare fino a questa*/
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                }
                .alert("Remove from Library?", isPresented: $showRemoveAlert, presenting: bookToRemove) { book in
                    Button("Remove", role: .destructive) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            context.delete(book)
                            do {
                                try context.save()
                                print("🗑️ Removed: \(book.title)")
                            } catch {
                                print("❌ Delete error: \(error)")
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: { book in
                    Text("Are you sure you want to remove \"\(book.title)\" from your library?")
                }
            }
        }
        .padding(.top, 8)
    }
}


struct addBookButtonView: View {
    var isSaved: Bool
    var body: some View {
        ZStack {
            Text(isSaved ? "In Your Library" : "Add to My Library")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.vertical, 6)
            
            HStack {
                Image(systemName: isSaved ? "checkmark" : "plus")
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity)
        .background(isSaved ? Color.pastelGreen : Color.terracotta)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .animation(.easeInOut(duration: 0.25), value: isSaved)
    }
}


struct BookRowView: View {
    let book: BookAPI
    let isSaved: Bool
    let savedBook: SavedBook?
    let onSaveTapped: () -> Void
    let onDeleteTapped: () -> Void
    let onStatusChange: (ReadingStatus) -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let urlString = book.coverURL {
                AsyncImageView(urlString: urlString)
                    .frame(width: 60, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                noBookCoverUrlView(width: 60, height: 100, bookTitle: book.title)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(book.authors.joined(separator: ", "))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(book.publisher == "Unknown" ? " " : book.publisher)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Button(action: onSaveTapped) {
                        addBookButtonView(isSaved: isSaved)
                    }
                    
                    if let existing = savedBook {
                        Menu {
                            ForEach(ReadingStatus.assignableCases, id: \.self) { status in
                                Button {
                                    onStatusChange(status)
                                } label: {
                                    Label(status.rawValue.capitalized, systemImage: status.iconName)
                                }
                            }
                        } label: {
                            Circle()
                                .fill(existing.readingStatus.color)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                )
                                .animation(.easeInOut(duration: 0.25), value: existing.readingStatus)
                        }
                        .menuOrder(.fixed)
                    }
                }
            }
            .padding(.top, 4)
        }
    }
}


#Preview {
    AddBooksView()
}

import SwiftUI

struct SearchResultList: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var books: [BookAPI]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                ForEach(books) { book in
                    
                    NavigationLink  {
                        BookDetailsView(book: book)
                    }
                    label: {
                        HStack(alignment: .top, spacing: 12) {
                            if let urlString = book.coverURL {
                                
                                AsyncImageView(urlString: urlString)
                                /*AsyncImage(url: URL(string: urlString)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ZStack {
                                        Color.gray.opacity(0.3)
                                        ProgressView()
                                    }
                                }*/
                                .frame(width: 60, height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 60, height: 90)
                                        .shadow(radius: 2)
                                    
                                    Image(systemName: "book.closed")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(book.title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                
                                Text(book.authors.joined(separator: ", "))
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                
                                Text(book.publisher == "Unknown" ? " " : book.publisher)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                
                                
                                Button(action: {
                                    let saved = SavedBook(from: book)
                                    context.insert(saved)
                                    
                                    DispatchQueue.main.async {
                                        do {
                                            try context.save()
                                            print("✅ Saved: \(saved.title)")
                                            dismiss()
                                        } catch {
                                            print("❌ Save error: \(error)")
                                        }
                                    }
                                }) {
                                    Text("Add to My Library")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 6)
                                        .background(Color.terracotta)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.top, 8)
    }
}

#Preview {
    AddBooksView()
}

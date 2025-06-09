import SwiftUI

struct SearchResultList: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    var books: [BookAPI]
    
    var body: some View {
            VStack(spacing: 12) {
                ForEach(books) { book in
                    HStack(alignment: .top, spacing: 12) {
                        if let urlString = book.coverURL, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 60, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
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
                            
                            if let categories = book.categories {
                                HStack {
                                    ForEach(categories.prefix(2), id: \.self) { cat in
                                        Text(cat)
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.terracotta)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            
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
            .padding(.top, 8)
    }
}

#Preview {
    AddBooksView()
}

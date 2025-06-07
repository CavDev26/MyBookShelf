import SwiftUI

struct SearchResultList: View {
    @Environment(\.modelContext) private var context

    var books: [BookAPI]
    @Environment(\.dismiss) var dismiss

    
    var body: some View {
        //ScrollView {
            ForEach(books) { book in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        if let urlString = book.coverURL, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 60, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(book.title)
                                .font(.headline)
                            
                            Text(book.authors.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            if let cat = book.categories {
                                ForEach(cat, id: \.self) { c in
                                    Text(c)
                                        .font(.caption2)
                                }
                                
                            }
                            
                            Button("Add to My Library") {
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
                            }
                            .font(.caption)
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
            //}
        }
    }
}

#Preview {
    TestView()
}

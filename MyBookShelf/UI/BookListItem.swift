import SwiftUI
import _SwiftData_SwiftUI


struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        }
    }
}







struct BookListItemGrid: View {
    var book: Book
    var readingStatusColor: Color {
        switch book.readingStatus{
        case .reading:
            return Color.blue
        case .read:
            return Color.green
        case .unread:
            return Color.red
        }
    }
    

    var body: some View {
        
        ZStack(alignment: .topLeading){
            Color.clear
            Text(book.name)
                .padding(-5)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(alignment: .bottomTrailing) {

            AsyncImage(
                url: book.imageUrl,
                content: { image in image.resizable() },
                placeholder: { ProgressView().tint(.blue) }
            )
            Triangle()
            .frame(width: 60, height: 60)
            .foregroundColor(readingStatusColor)
            .offset(x: 60, y: 60)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct BookListItemList: View {
    var book: Book
        
    var readingStatusColor: Color {
        switch book.readingStatus{
        case .reading:
            return Color.blue
        case .read:
            return Color.green
        case .unread:
            return Color.red
        }
    }
        let stripeHeight = 10.0
        var body: some View {
            HStack(alignment: .top) {
                AsyncImage(
                    url: book.imageUrl,
                    content: { image in image.resizable() },
                    placeholder: { ProgressView().tint(.blue) }
                )
                .frame(width: 60, height: 60)
                    .background(.tint.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading) {
                    Text(book.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(book.tripDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Text(
                        book.date,
                        format: Date.FormatStyle()
                            .day(.defaultDigits)
                            .month(.wide)
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }.frame(maxWidth: .infinity)
            .padding()
            .padding(.top, stripeHeight)
            .background {
                ZStack(alignment: .top) {
                    Rectangle()
                        .opacity(0.1)
                    Rectangle()
                        .frame(maxHeight: stripeHeight)
                }
                .overlay(alignment: .bottomTrailing)        {
                    Triangle()
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color(red: 0.6862745098039216, green: 0.8235294117647058, blue: 0.6549019607843137))
                        .offset(x: 30, y: 20)
                    
                    Triangle()
                        .frame(width: 60, height: 60)
                        .foregroundColor(readingStatusColor)
                        .offset(x: 30, y: 25)
                    
            }
            .foregroundColor(Color(red: 0.6862745098039216, green: 0.8235294117647058, blue: 0.6549019607843137))
            }
            .clipShape(RoundedRectangle(cornerRadius: stripeHeight, style: .continuous))
    }
}

#Preview {
    MyBooksView().modelContainer(PreviewData.makeModelContainer())
}

import SwiftUI
import _SwiftData_SwiftUI

struct BookListItemGrid: View {
    var book: Book
    var showStatus: Bool
    var readingStatusColor: Color {
        switch book.readingStatus{
        case .reading:
            return Color(red: 130/255, green: 180/255, blue: 230/255)
        case .read:
            return Color(red: 142/255, green: 197/255, blue: 160/255)
        case .unread:
            return Color(red: 216/255, green: 190/255, blue: 168/255)
        }
    }
    
    var body: some View {
        VStack {
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
                if(!showStatus) {
                    Triangle()
                    .frame(width: 60, height: 60)
                    .foregroundColor(readingStatusColor)
                    .offset(x: 60, y: 60)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            if(showStatus) {
                progressView(book: book)
            }
        }.shadow(color: Color.black.opacity(0.40), radius: 4, x: 5, y: 4)
    }
}

struct BookListItemList2: View {
    var book: Book
        
    var readingStatusColor: Color {
        switch book.readingStatus{
        case .reading:
            return Color(red: 130/255, green: 180/255, blue: 230/255)
        case .read:
            return Color(red: 142/255, green: 197/255, blue: 160/255)
        case .unread:
            return Color(red: 216/255, green: 190/255, blue: 168/255)
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

struct BookListItemList: View {
    var book: Book

    var readingStatusColor: Color {
        switch book.readingStatus {
        case .reading:
            return Color(red: 130/255, green: 180/255, blue: 230/255)
        case .read:
            return Color(red: 142/255, green: 197/255, blue: 160/255)
        case .unread:
            return Color(red: 216/255, green: 190/255, blue: 168/255)
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            AsyncImage(
                url: book.imageUrl,
                content: { image in image.resizable() },
                placeholder: { ProgressView().tint(.blue) }
            )
            .aspectRatio(1, contentMode: .fill)
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(book.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(book.tripDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text(book.date, format: Date.FormatStyle().day().month(.wide))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Badge di stato lettura
            Circle()
                .fill(readingStatusColor)
                .frame(width: 12, height: 12)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 4, x: 2, y: 2)
        )
        //.padding(.horizontal)
        .padding(.vertical, 3)
    }
}



struct progressView : View {
    @State var size: CGSize = .zero
    var book: Book
    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 20)
                    .foregroundColor(Color.red)
                    .saveSize(in: $size)
                Rectangle()
                    .frame(width: CGFloat(book.pagesRead) * size.width / CGFloat(book.pages), height: 20)
                    .foregroundColor(Color.green)
            }.clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            let v = CGFloat(book.pagesRead) / CGFloat(book.pages)
            //ProgressView(value: v)
            HStack {
                Text("\(Int(v*100))%")
                    .font(.system(size: 12))
                Button(action: {
                    //TODO porta direttamente all'aggiornamento del progresso
                }) {
                    Text("Update")
                        .font(.system(size: 12))
                    
                }.background {
                    Color.brown
                }
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .frame(width: .infinity)
            }
            .frame(width: .infinity, height: 20)
        }
    }
}


#Preview {
    MyBooksView2().modelContainer(PreviewData.makeModelContainer())
}

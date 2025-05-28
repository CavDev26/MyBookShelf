//
//  TripListItem.swift
//  TravelDiary
//
//  Created by Gianni Tumedei on 07/05/25.
//

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





struct BookListItem: View {
    var book: Book

    var body: some View {
    
        AsyncImage(
            url: book.imageUrl,
            content: { image in image.resizable() },
            placeholder: { ProgressView().tint(.blue) }
        )
        .clipShape(.rect(cornerRadius: 10))
        
        
        
        
        /*HStack {
            AsyncImage(
                url: book.imageUrl,
                content: { image in image.resizable() },
                placeholder: { ProgressView().tint(.blue) }
            )
            .frame(width: 50, height: 50)
            .background(.tint.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            Spacer().frame(width: 16)
            Text(book.name)
        }*/
    }
}

struct BookListItem2: View {
    var book: Book
        
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
                        .opacity(0.3)
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
                        .foregroundColor(.blue)
                        .offset(x: 30, y: 25)
                    
                }
                .foregroundColor(Color(red: 0.6862745098039216, green: 0.8235294117647058, blue: 0.6549019607843137))
                //.foregroundColor(Color(red: 175.0, green: 210.0, blue: 167.0))
            }
            .clipShape(RoundedRectangle(cornerRadius: stripeHeight, style: .continuous))
        
        
        
        
        
        
        
        /*HStack(alignment: .top, spacing: 12) {
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
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
                Text(book.tripDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, maxHeight: 70, alignment: .leading)
        }*/
    }
}

#Preview {
    BookListView().modelContainer(PreviewData.makeModelContainer())
}

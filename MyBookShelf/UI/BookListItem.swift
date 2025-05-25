//
//  TripListItem.swift
//  TravelDiary
//
//  Created by Gianni Tumedei on 07/05/25.
//

import SwiftUI
import _SwiftData_SwiftUI

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
    var body: some View {
        HStack {
            AsyncImage(
                url: book.imageUrl,
                content: { image in image.resizable() },
                placeholder: { ProgressView().tint(.blue) }
            )
            .frame(width: 60, height: 60)
            .background(.tint.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            Spacer().frame(width: 16)
            Text(book.name)
            Text(book.tripDescription)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    BookListView().modelContainer(PreviewData.makeModelContainer())
}

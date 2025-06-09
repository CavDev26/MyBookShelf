import SwiftData
import Foundation

enum PreviewData2 {
    static let sampleBooks2 = [
        SavedBook(
            id: "preview1-id",
            title: "The Swift Adventure",
            authors: ["Jane Appleseed"],
            publisher: "Cupertino Books",
            coverURL: "https://play.google.com/books/publisher/content/images/frontcover/330pEQAAQBAJ?fife=w480-h690",
            pageCount: 320,
            bookDescription: "Un viaggio attraverso Swift e SwiftUI.",
            publishedDate: "2024-01-01",
            industryIdentifiers: [],
            categories: ["Programming"],
            mainCategory: "Development",
            averageRating: 4.5,
            ratingsCount: 42,
            readingStatus: .read,
            pagesRead: 320
        ),
        SavedBook(
            id: "preview2-id",
            title: "The Swift Adventure",
            authors: ["Jane Appleseed"],
            publisher: "Cupertino Books",
            coverURL: "https://upload.wikimedia.org/wikipedia/commons/a/a1/La_rocca_malatestiana_di_Cesena.jpg",
            pageCount: 100,
            bookDescription: "Un viaggio attraverso Swift e SwiftUI.",
            publishedDate: "2024-01-01",
            industryIdentifiers: [],
            categories: ["Programming"],
            mainCategory: "Development",
            averageRating: 4.5,
            ratingsCount: 42,
            readingStatus: .reading,
            pagesRead: 30
        ),
        SavedBook(
            id: "preview3-id",
            title: "The Swift Adventure",
            authors: ["Jane Appleseed"],
            publisher: "Cupertino Books",
            coverURL: "https://upload.wikimedia.org/wikipedia/commons/a/a1/La_rocca_malatestiana_di_Cesena.jpg",
            pageCount: 500,
            bookDescription: "Un viaggio attraverso Swift e SwiftUI.",
            publishedDate: "2024-01-01",
            industryIdentifiers: [],
            categories: ["Programming"],
            mainCategory: "Development",
            averageRating: 4.5,
            ratingsCount: 42,
            readingStatus: .unread
        )
    ]
    static func makeModelContainer(
        for entities: [any PersistentModel.Type] = [SavedBook.self],
        withSampleData: Bool = true

    ) -> ModelContainer {
        // Create container
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema(entities)
        let container = try! ModelContainer(for: schema, configurations: config)

        // Add sample data if requested
        if withSampleData {
            let modelContext = ModelContext(container)
            for book in sampleBooks2 {
                modelContext.insert(book)
            }
            try! modelContext.save()
        }
        return container
    }
}



enum PreviewData {
    static let sampleBooks = [
        Book(
            name: "libro1(letto)",
            date: .now,
            tripDescription:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            image:
                "https://upload.wikimedia.org/wikipedia/commons/a/a1/La_rocca_malatestiana_di_Cesena.jpg",
            latitude: 44.136,
            longitude: 12.237,
            readingStatus: .read,
            pages: 100,
            pagesRead: 0
        ),
        Book(
            name: "libro2(letto)",
            date: .now,
            tripDescription:
                "Praesent volutpat, neque ac eleifend dapibus, velit nisl placerat erat, vel dapibus nisi velit vel arcu.",
            image:
                "https://magazine.unibo.it/archivio/2018/inaugurato-il-nuovo-campus-di-cesena-allex-zuccherificio/cesena2.jpeg",
            latitude: 44.136,
            longitude: 12.23,
            readingStatus: .read,
            pages: 100,
            pagesRead: 100
        ),
        Book(
            name: "Libro3(nonletto)",
            date: .now,
            tripDescription:
                "Praesent volutpat, neque ac eleifend dapibus, velit nisl placerat erat, vel dapibus nisi velit vel arcu.",
            image:
                "https://magazine.unibo.it/archivio/2018/inaugurato-il-nuovo-campus-di-cesena-allex-zuccherificio/cesena2.jpeg",
            latitude: 44.136,
            longitude: 12.23,
            readingStatus: .unread,
            pages: 100,
            pagesRead: 0
        ),
        Book(
            name: "libro4(leggendo)",
            date: .now,
            tripDescription:
                "Praesent volutpat, neque ac eleifend dapibus, velit nisl placerat erat, vel dapibus nisi velit vel arcu.",
            image:
                "https://magazine.unibo.it/archivio/2018/inaugurato-il-nuovo-campus-di-cesena-allex-zuccherificio/cesena2.jpeg",
            latitude: 44.136,
            longitude: 12.23,
            readingStatus: .reading,
            pages: 100,
            pagesRead: 20
        ),
        Book(
            name: "libro5(nonLetto)",
            date: .now,
            tripDescription:
                "Praesent volutpat, neque ac eleifend dapibus, velit nisl placerat erat, vel dapibus nisi velit vel arcu.",
            image:
                "https://magazine.unibo.it/archivio/2018/inaugurato-il-nuovo-campus-di-cesena-allex-zuccherificio/cesena2.jpeg",
            latitude: 44.136,
            longitude: 12.23,
            readingStatus: .unread,
            pages: 100,
            pagesRead: 0
        ),
        Book(
            name: "libro6(leggendo)",
            date: .now,
            tripDescription:
                "Praesent volutpat, neque ac eleifend dapibus, velit nisl placerat erat, vel dapibus nisi velit vel arcu.",
            image:
                "https://magazine.unibo.it/archivio/2018/inaugurato-il-nuovo-campus-di-cesena-allex-zuccherificio/cesena2.jpeg",
            latitude: 44.136,
            longitude: 12.23,
            readingStatus: .reading,
            pages: 200,
            pagesRead: 100
        ),
        Book(
            name: "Libro7(nonletto)",
            date: .now,
            tripDescription:
                "Praesent volutpat, neque ac eleifend dapibus, velit nisl placerat erat, vel dapibus nisi velit vel arcu.",
            image:
                "https://magazine.unibo.it/archivio/2018/inaugurato-il-nuovo-campus-di-cesena-allex-zuccherificio/cesena2.jpeg",
            latitude: 44.136,
            longitude: 12.23,
            readingStatus: .unread,
            pages: 100,
            pagesRead: 0
        ),
        Book(
            name: "libro8(nonletto)",
            date: .now,
            tripDescription:
                "Praesent volutpat, neque ac eleifend dapibus, velit nisl placerat erat, vel dapibus nisi velit vel arcu.",
            image:
                "https://magazine.unibo.it/archivio/2018/inaugurato-il-nuovo-campus-di-cesena-allex-zuccherificio/cesena2.jpeg",
            latitude: 44.136,
            longitude: 12.23,
            readingStatus: .unread,
            pages: 100,
            pagesRead: 0
        ),
        Book(
            name: "libro9(nonletto)",
            date: .now,
            tripDescription:
                "Praesent volutpat, neque ac eleifend dapibus, velit nisl placerat erat, vel dapibus nisi velit vel arcu.",
            image:
                "https://magazine.unibo.it/archivio/2018/inaugurato-il-nuovo-campus-di-cesena-allex-zuccherificio/cesena2.jpeg",
            latitude: 44.136,
            longitude: 12.23,
            readingStatus: .unread,
            pages: 100,
            pagesRead: 0
        ),
        Book(
            name: "Libro10(nonletto)",
            date: .now,
            tripDescription:
                "Praesent volutpat, neque ac eleifend dapibus, velit nisl placerat erat, vel dapibus nisi velit vel arcu.",
            image:
                "https://magazine.unibo.it/archivio/2018/inaugurato-il-nuovo-campus-di-cesena-allex-zuccherificio/cesena2.jpeg",
            latitude: 44.136,
            longitude: 12.23,
            readingStatus: .unread,
            pages: 100,
            pagesRead: 0
        ),
        
    ]

    static func makeModelContainer(
        for entities: [any PersistentModel.Type] = [Book.self],
        withSampleData: Bool = true
    ) -> ModelContainer {
        // Create container
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema(entities)
        let container = try! ModelContainer(for: schema, configurations: config)

        // Add sample data if requested
        if withSampleData {
            let modelContext = ModelContext(container)
            for trip in sampleBooks {
                modelContext.insert(trip)
            }
            try! modelContext.save()
        }

        return container
    }
}

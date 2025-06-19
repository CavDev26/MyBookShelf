/*import SwiftData
import Foundation

enum PreviewData2 {
    
    static let sampleBooks2: [SavedBook] = [
    SavedBook(
                id: "sample1-id",
                title: "The Swift Adventure",
                authors: ["Jane Appleseed"],
                publisher: "Cupertino Books",
                coverURL: "https://covers.openlibrary.org/b/id/10521283-L.jpg",
                pageCount: 375,
                bookDescription: "Una riflessione sul controllo e la libertà.",
                publishedDate: "2024-01-01",
                industryIdentifiers: [],
                categories: [],
                mainCategory: nil,
                averageRating: 4.5,
                ratingsCount: 42,
                readingStatus: .reading,
                pagesRead: 47,
                favourite: false,
                genres: nil
            ),
    SavedBook(
                id: "sample2-id",
                title: "Il Signore degli Anelli",
                authors: ["F. Scott Fitzgerald"],
                publisher: "Cupertino Books",
                coverURL: "https://covers.openlibrary.org/b/id/11107858-L.jpg",
                pageCount: 364,
                bookDescription: "Un classico della fantascienza moderna.",
                publishedDate: "2024-01-01",
                industryIdentifiers: [],
                categories: [],
                mainCategory: nil,
                averageRating: 4.5,
                ratingsCount: 42,
                readingStatus: .reading,
                pagesRead: 320,
                favourite: false,
                genres: nil
            ),
    SavedBook(
                id: "sample3-id",
                title: "Lo Hobbit",
                authors: ["J.R.R. Tolkien"],
                publisher: "Cupertino Books",
                coverURL: "https://covers.openlibrary.org/b/id/11107858-L.jpg",
                pageCount: 425,
                bookDescription: "Una riflessione sul controllo e la libertà.",
                publishedDate: "2024-01-01",
                industryIdentifiers: [],
                categories: [],
                mainCategory: nil,
                averageRating: 4.5,
                ratingsCount: 42,
                readingStatus: .read,
                pagesRead: 425,
                favourite: false,
                genres: nil
            ),
    SavedBook(
                id: "sample4-id",
                title: "Dune",
                authors: ["Aldous Huxley"],
                publisher: "Cupertino Books",
                coverURL: "https://upload.wikimedia.org/wikipedia/commons/a/a1/La_rocca_malatestiana_di_Cesena.jpg",
                pageCount: 722,
                bookDescription: "Una storia d'amore senza tempo.",
                publishedDate: "2024-01-01",
                industryIdentifiers: [],
                categories: [],
                mainCategory: nil,
                averageRating: 4.5,
                ratingsCount: 42,
                readingStatus: .unread,
                pagesRead: 0,
                favourite: false,
                genres: nil
            ),
    SavedBook(
                id: "sample5-id",
                title: "Foundation",
                authors: ["Jane Appleseed"],
                publisher: "Cupertino Books",
                coverURL: "https://upload.wikimedia.org/wikipedia/commons/a/a1/La_rocca_malatestiana_di_Cesena.jpg",
                pageCount: 300,
                bookDescription: "Un classico della fantascienza moderna.",
                publishedDate: "2024-01-01",
                industryIdentifiers: [],
                categories: [],
                mainCategory: nil,
                averageRating: 4.5,
                ratingsCount: 42,
                readingStatus: .reading,
                pagesRead: 87,
                favourite: false,
                genres: nil
            ),
    SavedBook(
                id: "sample6-id",
                title: "1984",
                authors: ["Leo Tolstoy"],
                publisher: "Cupertino Books",
                coverURL: "https://upload.wikimedia.org/wikipedia/commons/a/a1/La_rocca_malatestiana_di_Cesena.jpg",
                pageCount: 277,
                bookDescription: "Una storia d'amore senza tempo.",
                publishedDate: "2024-01-01",
                industryIdentifiers: [],
                categories: [],
                mainCategory: nil,
                averageRating: 4.5,
                ratingsCount: 42,
                readingStatus: .read,
                pagesRead: 277,
                favourite: true,
                genres: nil
            ),
    SavedBook(
                id: "sample7-id",
                title: "Pride and Prejudice",
                authors: ["Isaac Asimov"],
                publisher: "Cupertino Books",
                coverURL: "https://covers.openlibrary.org/b/id/10521283-L.jpg",
                pageCount: 551,
                bookDescription: "Una riflessione sul controllo e la libertà.",
                publishedDate: "2024-01-01",
                industryIdentifiers: [],
                categories: [],
                mainCategory: nil,
                averageRating: 4.5,
                ratingsCount: 42,
                readingStatus: .read,
                pagesRead: 551,
                favourite: false,
                genres: nil
            ),
    SavedBook(
                id: "sample8-id",
                title: "To Kill a Mockingbird",
                authors: ["Jane Austen"],
                publisher: "Cupertino Books",
                coverURL: "https://covers.openlibrary.org/b/id/11107858-L.jpg",
                pageCount: 798,
                bookDescription: "Una riflessione sul controllo e la libertà.",
                publishedDate: "2024-01-01",
                industryIdentifiers: [],
                categories: [],
                mainCategory: nil,
                averageRating: 4.5,
                ratingsCount: 42,
                readingStatus: .read,
                pagesRead: 798,
                favourite: true,
                genres: nil
            ),
    SavedBook(
                id: "sample9-id",
                title: "Moby Dick",
                authors: ["Ray Bradbury"],
                publisher: "Cupertino Books",
                coverURL: "https://upload.wikimedia.org/wikipedia/commons/a/a1/La_rocca_malatestiana_di_Cesena.jpg",
                pageCount: 446,
                bookDescription: "Una storia d'amore senza tempo.",
                publishedDate: "2024-01-01",
                industryIdentifiers: [],
                categories: [],
                mainCategory: nil,
                averageRating: 4.5,
                ratingsCount: 42,
                readingStatus: .unread,
                pagesRead: 0,
                favourite: false,
                genres: nil
            ),
    SavedBook(
                id: "sample10-id",
                title: "Brave New World",
                authors: ["Aldous Huxley"],
                publisher: "Cupertino Books",
                coverURL: "https://covers.openlibrary.org/b/id/11107858-L.jpg",
                pageCount: 267,
                bookDescription: "Una riflessione sul controllo e la libertà.",
                publishedDate: "2024-01-01",
                industryIdentifiers: [],
                categories: [],
                mainCategory: nil,
                averageRating: 4.5,
                ratingsCount: 42,
                readingStatus: .reading,
                pagesRead: 31,
                favourite: true,
                genres: nil
            ),
    SavedBook(
                id: "sample11-id",
                title: "The Catcher in the Rye",
                authors: ["F. Scott Fitzgerald"],
                publisher: "Cupertino Books",
                coverURL: "https://upload.wikimedia.org/wikipedia/commons/a/a1/La_rocca_malatestiana_di_Cesena.jpg",
                pageCount: 212,
                bookDescription: "Una riflessione sul controllo e la libertà.",
                publishedDate: "2024-01-01",
                industryIdentifiers: [],
                categories: [],
                mainCategory: nil,
                averageRating: 4.5,
                ratingsCount: 42,
                readingStatus: .unread,
                pagesRead: 0,
                favourite: false,
                genres: nil
            ),
    SavedBook(
                id: "sample12-id",
                title: "Fahrenheit 451",
                authors: ["George Orwell"],
                publisher: "Cupertino Books",
                coverURL: "https://covers.openlibrary.org/b/id/10521283-L.jpg",
                pageCount: 633,
                bookDescription: "Una storia d'amore senza tempo.",
                publishedDate: "2024-01-01",
                industryIdentifiers: [],
                categories: [],
                mainCategory: nil,
                averageRating: 4.5,
                ratingsCount: 42,
                readingStatus: .reading,
                pagesRead: 26,
                favourite: false,
                genres: nil
            ),
    SavedBook(
                id: "sample13-id",
                title: "The Great Gatsby",
                authors: ["Jane Austen"],
                publisher: "Cupertino Books",
                coverURL: "https://covers.openlibrary.org/b/id/10521283-L.jpg",
                pageCount: 811,
                bookDescription: "Una riflessione sul controllo e la libertà.",
                publishedDate: "2024-01-01",
                industryIdentifiers: [],
                categories: [],
                mainCategory: nil,
                averageRating: 4.5,
                ratingsCount: 42,
                readingStatus: .unread,
                pagesRead: 0,
                favourite: true,
                genres: nil
            ),
    SavedBook(
                id: "sample14-id",
                title: "Dracula",
                authors: ["Isaac Asimov"],
                publisher: "Cupertino Books",
                coverURL: "https://covers.openlibrary.org/b/id/11032721-L.jpg",
                pageCount: 823,
                bookDescription: "Una storia d'amore senza tempo.",
                publishedDate: "2024-01-01",
                industryIdentifiers: [],
                categories: [],
                mainCategory: nil,
                averageRating: 4.5,
                ratingsCount: 42,
                readingStatus: .unread,
                pagesRead: 0,
                favourite: true,
                genres: nil
            ),
    SavedBook(
                id: "sample15-id",
                title: "War and Peace",
                authors: ["F. Scott Fitzgerald"],
                publisher: "Cupertino Books",
                coverURL: "https://covers.openlibrary.org/b/id/10521283-L.jpg",
                pageCount: 780,
                bookDescription: "Una riflessione sul controllo e la libertà.",
                publishedDate: "2024-01-01",
                industryIdentifiers: [],
                categories: [],
                mainCategory: nil,
                averageRating: 4.5,
                ratingsCount: 42,
                readingStatus: .unread,
                pagesRead: 0,
                favourite: true,
                genres: nil
            )
    ]

    
    
    
    
    
    
    
    static let sampleBooks3 = [
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
            pagesRead: 320,
            favourite: true,
            genres: nil
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
            pagesRead: 30,
            genres: nil
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
            readingStatus: .unread,
            genres: nil
        ),
        SavedBook(
            id: "preview4-id",
            title: "il signore degli anelli",
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
            pagesRead: 320,
            genres: nil
        ),
        SavedBook(
            id: "preview5-id",
            title: "lo hobbit",
            authors: ["tolkien"],
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
            pagesRead: 320,
            favourite: true,
            genres: nil
        ),
        SavedBook(
            id: "preview6-id",
            title: "Dune",
            authors: ["tolkien"],
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
            pagesRead: 320,
            genres: nil
        ),
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
*/

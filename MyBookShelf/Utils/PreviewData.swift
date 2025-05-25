//
//  PreviewModelContainer.swift
//  TravelDiary
//
//  Created by Gianni Tumedei on 14/05/25.
//

import SwiftData

enum PreviewData {
    static let sampleBooks = [
        Book(
            name: "Rocca di Cesena",
            date: .now,
            tripDescription:
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            image:
                "https://upload.wikimedia.org/wikipedia/commons/a/a1/La_rocca_malatestiana_di_Cesena.jpg",
            latitude: 44.136,
            longitude: 12.237
        ),
        Book(
            name: "Campus di Cesena",
            date: .now,
            tripDescription:
                "Praesent volutpat, neque ac eleifend dapibus, velit nisl placerat erat, vel dapibus nisi velit vel arcu.",
            image:
                "https://magazine.unibo.it/archivio/2018/inaugurato-il-nuovo-campus-di-cesena-allex-zuccherificio/cesena2.jpeg",
            latitude: 44.136,
            longitude: 12.23
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

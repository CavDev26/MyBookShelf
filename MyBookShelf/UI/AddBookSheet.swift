//
//  AddTripSheet.swift
//  TravelDiary
//
//  Created by Gianni Tumedei on 07/05/25.
//

import SwiftUI

struct AddBookSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var date: Date = .now
    @State private var description: String = ""
    @State private var image: String = ""
    @State private var latitude: Double? = nil
    @State private var longitude: Double? = nil
    @State private var readingStatus: ReadingStatus = .unread
    @State private var pages: Int? = nil
    @State private var pagesRead: Int? = nil

    private var canSubmit: Bool { !name.isEmpty && !description.isEmpty }

    @State private var locationService = LocationService()

    var body: some View {
        NavigationStack {
            Form {
                Section(
                    content: {
                        TextField("Name", text: $name)
                        DatePicker(
                            "Date", selection: $date, displayedComponents: .date
                        )
                        TextField("Description", text: $description)
                    },
                    header: { Text("Trip details") }
                )

                Section(
                    content: {
                        TextField("Latitude", value: $latitude, format: .number)
                            .keyboardType(.numberPad)
                            .onChange(of: locationService.latitude) {
                                latitude = locationService.latitude
                            }
                        TextField(
                            "Longitude", value: $longitude, format: .number
                        )
                        .keyboardType(.numberPad)
                        .onChange(of: locationService.longitude) {
                            longitude = locationService.longitude
                        }

                        HStack {
                            Button(action: { locationService.requestLocation() }
                            ) {
                                Text("Get current location")
                            }
                            if locationService.isMonitoring {
                                Spacer()
                                ProgressView().tint(.blue)
                            }
                        }
                    },
                    header: { Text("Coordinates") }
                )

                Section(
                    content: {
                        TextField("Image URL", text: $image)
                    },
                    header: { Text("Image") }
                )
            }
            .navigationTitle("Add trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Save") {
                        if !canSubmit { return }
                        let book = Book(
                            name: name,
                            date: date,
                            tripDescription: description,
                            image: image,
                            latitude: latitude ?? 0,
                            longitude: longitude ?? 0,
                            readingStatus: readingStatus,
                            pages: pages ?? 0,
                            pagesRead: pagesRead ?? 0
                        )
                        modelContext.insert(book)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddBookSheet()
}

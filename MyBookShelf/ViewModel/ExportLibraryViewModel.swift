import Foundation
import SwiftUI
import UniformTypeIdentifiers

// Wrapper per rendere il file URL Identifiable
struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

class ExportLibraryViewModel: ObservableObject {
    @Published var exportFile: IdentifiableURL? = nil
    @Published var isExporting: Bool = false
    

    func exportLibrary(as format: ExportFormat, books: [SavedBook]) {
        isExporting = true

        DispatchQueue.global(qos: .userInitiated).async {
            let fileName = "MyLibrary_Export.\(format.fileExtension)"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            do {
                let data: Data

                let exportableBooks = books.map { $0.toExportable() }

                switch format {
                case .json:
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    data = try encoder.encode(exportableBooks)

                case .csv:
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .short
                    dateFormatter.timeStyle = .none
                    
                    let header = "Title,Authors,Publisher,PublishedDate,PageCount,ISBN,ReadingStatus,PagesRead,UserNotes,Rating,DateStarted,DateFinished\n"
                    
                    let rows = exportableBooks.map {
                        let started = $0.dateStarted.map { dateFormatter.string(from: $0) } ?? "---"
                        let finished = $0.dateFinished.map { dateFormatter.string(from: $0) } ?? "---"
                        
                        return "\"\($0.title)\",\"\($0.authors.joined(separator: ", "))\",\"\($0.publisher)\",\"\($0.publishedDate ?? "")\","
                            + "\($0.pageCount ?? 0),\"\($0.isbn ?? "")\",\"\($0.readingStatus)\",\($0.pagesRead),"
                            + "\"\($0.userNotes.replacingOccurrences(of: "\"", with: "'"))\","
                            + "\($0.rating ?? 0),\"\(started)\",\"\(finished)\""
                    }
                    let csv = header + rows.joined(separator: "\n")
                    data = Data(csv.utf8)
                }

                try data.write(to: tempURL, options: .atomic)

                DispatchQueue.main.async {
                    self.exportFile = IdentifiableURL(url: tempURL)
                    self.isExporting = false
                }
            } catch {
                print("Export error: \(error)")
                DispatchQueue.main.async {
                    self.isExporting = false
                }
            }
        }
    }
}

enum ExportFormat: String, CaseIterable, Identifiable {
    case json, csv
    var id: String { rawValue }

    var fileExtension: String {
        switch self {
        case .json: return "json"
        case .csv: return "csv"
        }
    }
}

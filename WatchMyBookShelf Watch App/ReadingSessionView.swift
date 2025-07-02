import SwiftUI
import WatchConnectivity

struct ReadingSessionView: View {
    var book: WatchBook

    @State private var selectedDuration: Int = 15
    @State private var isReading = false
    @State private var timeRemaining: Int = 15 * 60
    @State private var timer: Timer?
    @State private var showUpdateProgress = false

    var body: some View {
        VStack(spacing: 8) {

            if isReading {
                Text("Reading…")
                    .font(.title3)
                Text("\(formattedTime)")
                    .font(.largeTitle)
                    .monospacedDigit()
                Button("Stop") {
                    endSession()
                }
                .foregroundColor(.red)
            } else {
                Text("Set Duration")
                    .font(.subheadline)
                Picker("Duration", selection: $selectedDuration) {
                    ForEach([15, 30, 45], id: \.self) { minutes in
                        Text("\(minutes) min").tag(minutes)
                    }
                }
                .labelsHidden()
                Button("Start Reading") {
                    startSession()
                }
                .padding(.top)
            }
        }
        .navigationTitle(book.title)
        .padding()
        .onDisappear {
            timer?.invalidate()
        }
        .sheet(isPresented: $showUpdateProgress) {
            UpdateProgressView(book: book, durationMinutes: selectedDuration)
        }
    }

    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func startSession() {
        isReading = true
        timeRemaining = selectedDuration * 60
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                endSession()
            }
        }
    }

    func endSession() {
        timer?.invalidate()
        isReading = false
        showUpdateProgress = true
    }
}



import SwiftUI
import WatchConnectivity

struct UpdateProgressView: View {
    var book: WatchBook
    var durationMinutes: Int

    @State private var currentPage: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text("A che pagina sei arrivato?")
                .font(.headline)
            TextField("Es. 120", text: $currentPage)
                //.keyboardType(.numberPad)

            Button("Invia") {
                if let page = Int(currentPage) {
                    let info: [String: Any] = [
                        "type": "readingSession",
                        "bookID": book.id,
                        "durationMinutes": durationMinutes,
                        "timestamp": Date().timeIntervalSince1970,
                        "pagesRead": page,
                        "title": book.title
                    ]

                    if WCSession.default.isReachable {
                        WCSession.default.sendMessage(info, replyHandler: nil, errorHandler: nil)
                    } else {
                        WCSession.default.transferUserInfo(info)
                    }

                    dismiss()
                }
            }
        }
        .padding()
    }
}

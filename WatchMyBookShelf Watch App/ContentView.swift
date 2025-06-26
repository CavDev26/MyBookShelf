import SwiftUI
import WatchConnectivity

struct ReadingSessionView: View {
    @State private var selectedDuration: Int = 15
    @State private var isReading = false
    @State private var timeRemaining: Int = 15 * 60
    @State private var timer: Timer?

    var body: some View {
        VStack {
            if isReading {
                Text("Reading…")
                    .font(.title3)
                Text("\(formattedTime)")
                    .font(.largeTitle)
                    .monospacedDigit()
                    .padding()
                Button("Stop") {
                    endSession()
                }.foregroundColor(.red)
            } else {
                Text("Start a session")
                Picker("Duration", selection: $selectedDuration) {
                    ForEach([15, 30, 45], id: \.self) { minutes in
                        Text("\(minutes) min").tag(minutes)
                    }
                }
                .labelsHidden()

                Button("Start Reading") {
                    startSession()
                }.padding(.top)
            }
        }
        .onDisappear {
            timer?.invalidate()
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

        // 👉 Qui puoi inviare i dati a iOS via WatchConnectivity
        let info: [String: Any] = [
            "type": "readingSession",
            "durationMinutes": selectedDuration,
            "timestamp": Date().timeIntervalSince1970
        ]

        print("hai stoppato, preparo info: \(info)")
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(info, replyHandler: nil, errorHandler: nil)
        } else {
            WCSession.default.transferUserInfo(info)
        }
    }
}

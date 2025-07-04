import SwiftUI

struct ReadingDiaryView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedDate: Date = .now
    @State private var diaryText: String = ""
    @State private var isSaving: Bool = false
    @EnvironmentObject var auth: AuthManager
    @State private var lastSavedDate: Date = .now
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                .ignoresSafeArea()
            
            //ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                            .labelsHidden()
                            .padding(8)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Spacer()
                    }
                    .padding(.horizontal)
                    ZStack(alignment: .bottomTrailing) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)

                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $diaryText)
                                .scrollContentBackground(.hidden)
                                .padding()
                        }
                        .frame(minHeight: 500)
                    }
                    .padding(.horizontal)
                    
                }
                .padding(.bottom, 32)
            //}
        }
        .customNavigationTitle("Personal Diary")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            lastSavedDate = selectedDate
            loadDiary(for: selectedDate)
        }
        .onChange(of: selectedDate) { newDate in
            // Salva prima il diario del giorno precedente
            saveDiary(for: lastSavedDate)
            // Carica il diario del nuovo giorno
            loadDiary(for: newDate)
            // Aggiorna il riferimento
            lastSavedDate = newDate
        }        .onDisappear { saveDiary() }
    }
    
    func saveDiary(for date: Date = .now) {
        isSaving = true
        let key = formattedDate(date)
        FirebaseDiaryService.shared.saveEntry(for: key, text: diaryText, uid: auth.uid) {
            isSaving = false
        }
    }
    
    func loadDiary(for date: Date) {
        let key = formattedDate(date)
        FirebaseDiaryService.shared.loadEntry(for: key, uid: auth.uid) { text in
            diaryText = text ?? ""
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

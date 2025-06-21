import SwiftUI

struct ReadingDiaryView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedDate: Date = .now
    @State private var diaryText: String = ""
    @State private var isSaving: Bool = false
    @EnvironmentObject var auth: AuthManager
    
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
        .onAppear { loadDiary(for: selectedDate) }
        .onChange(of: selectedDate) { loadDiary(for: $0) }
        .onDisappear { saveDiary() }
    }
    
    func saveDiary() {
        isSaving = true
        let key = formattedDate(selectedDate)
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

import SwiftUI
import Charts
import SwiftData

struct GraphicsSectionView: View {
    @Query(sort: \SavedBook.dateFinished, order: .reverse) var books: [SavedBook]
    @State private var selectedYear = Calendar.current.component(.year, from: .now)
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.terracotta)
                    .frame(width: 4, height: 20)

                Text("Year Overview")
                    .modifier(TitleTextMod(size: 20))
            }
            .padding(.bottom)
            HStack{
                Menu {
                    ForEach(availableYears, id: \.self) { year in
                        Button(action: {
                            selectedYear = year
                        }) {
                            Text("\(year)")
                        }
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                            .frame(width: 200, height: 30)
                        HStack {
                            Text("\(selectedYear)")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .font(.caption)
                                .bold()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom)

            Chart(monthlyData) { stat in
                BarMark(
                    x: .value("Month", String(stat.month)), // forza categoria testuale
                    y: .value("Books Finished", stat.count)
                )
                .foregroundStyle(Color.terracotta)
            }
            .chartXAxis {
                AxisMarks(values: Array(1...12).map { String($0) }) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(centered: true) {
                        if let str = value.as(String.self),
                           let intVal = Int(str) {
                            Text(String(monthLabel(for: intVal).prefix(1)))
                                .font(.caption2)
                        }
                    }
                }
            }
            .frame(height: 200)
        }
        .padding(.top, 8)
        .modifier(ChallengesBlockMod())
    }

    var monthlyData: [MonthlyReadingStat] {
        var stats: [MonthlyReadingStat] = []
        for month in 1...12 {
            let count = books.filter {
                guard let date = $0.dateFinished else { return false }
                let components = Calendar.current.dateComponents([.year, .month], from: date)
                return components.year == selectedYear && components.month == month
            }.count
            stats.append(MonthlyReadingStat(month: month, count: count))
        }
        return stats
    }

    var availableYears: [Int] {
        let years = books.compactMap { book in
            book.dateFinished.flatMap { Calendar.current.component(.year, from: $0) }
        }
        return Array(Set(years)).sorted(by: >)
    }

    func monthLabel(for month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.shortMonthSymbols[month - 1] // <-- attuale, restituisce "Jul"
    }
}

struct MonthlyReadingStat: Identifiable {
    var id: Int { month }
    let month: Int
    let count: Int
}

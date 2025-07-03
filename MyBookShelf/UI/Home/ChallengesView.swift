import SwiftUI
import _SwiftData_SwiftUI

struct ChallengesView: View {
    
    @Environment(\.modelContext) private var context
    @Query var yearlyChallenges: [YearlyReadingChallenge]
    @Query var monthlyChallenges: [MonthlyReadingChallenge]
    @StateObject private var auth = AuthManager()
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var currentYear: Int {
        Calendar.current.component(.year, from: .now)
    }
    
    var currentMonth: Int {
        Calendar.current.component(.month, from: .now)
    }
    
    @State var yearlyChallenge: YearlyReadingChallenge?
    @State var monthlyChallenge: MonthlyReadingChallenge?
    
    @State var showInfoLevelSheet: Bool = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 30) {
                            ReadingChallengeView(yChall: yearlyChallenge)
                            HStack(alignment: .top, spacing: 16) {
                                MonthlyGoalView(mChall: monthlyChallenge)
                                    .frame(maxWidth: .infinity, minHeight: 120, maxHeight: .infinity)
                                StreakTrackerView(months: monthlyChallenges.filter { $0.isCompleted }.count)
                                    .frame(maxWidth: .infinity, minHeight: 120, maxHeight: .infinity)
                            }
                            .frame(height: 120)
                            LevelSectionView(showInfoLevelSheet: $showInfoLevelSheet)
                            StatsSectionView()
                        }
                        .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $showInfoLevelSheet) {
            LevelInfoSheetView()
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            let year = Calendar.current.component(.year, from: .now)
            let month = Calendar.current.component(.month, from: .now)
            
            if let yc = yearlyChallenges.first(where: { $0.year == year }) {
                yearlyChallenge = yc
            } else {
                let newChallenge = YearlyReadingChallenge(year: year, goal: 0)
                context.insert(newChallenge)
                yearlyChallenge = newChallenge
                print("📘 Yearly inserted: \(yearlyChallenge?.goal ?? -1)")
            }
            
            if let mc = monthlyChallenges.first(where: { $0.year == year && $0.month == month }) {
                monthlyChallenge = mc
            } else {
                let newChallenge = MonthlyReadingChallenge(year: year, month: month, goal: 0)
                context.insert(newChallenge)
                monthlyChallenge = newChallenge
                print("📘 Monthly inserted: \(monthlyChallenge?.goal ?? -1)")
            }
            
            try? context.save()
        }
        .customNavigationTitle("Challenges")
        /*.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    deleteAllChallenges()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }*/
    }
    /// DEBUG
    func deleteAllChallenges() {
        do {
            for yc in yearlyChallenges {
                context.delete(yc)
            }
            for mc in monthlyChallenges {
                context.delete(mc)
            }
            try context.save()
            yearlyChallenge = nil
            monthlyChallenge = nil
            do {
                let books = try context.fetch(FetchDescriptor<SavedBook>())
                StatsManager.shared.updateStats(using: books, in: context, uid: auth.uid)
            } catch {
                print("❌ Failed to update stats: \(error)")
            }
            print("🗑️ Tutte le challenge eliminate.")
        } catch {
            print("❌ Errore nella cancellazione delle challenge: \(error)")
        }
    }
}
struct ReadingChallengeView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var context
    
    var yChall: YearlyReadingChallenge?
    
    @State private var showSheet = false
    @State private var tempGoal = ""
    
    var goal: Int? {
        yChall?.goal
    }
    
    var current: Int {
        yChall?.booksFinished ?? 0
    }
    
    var progress: Double {
        guard let goal, goal > 0 else { return 0 }
        return Double(current) / Double(goal)
    }
    
    var motivationalMessage: String {
        guard let goal else { return "" }
        let delta = goal - current
        if delta <= 0 { return "Goal completed! 🎉" }
        else if delta <= 3 { return "Almost there! ✨" }
        else { return "Keep going! 📚" }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.terracotta)
                    .frame(width: 4, height: 20)
                Text("\(Calendar.current.component(.year, from: .now)) Reading Challenge")
                    .modifier(TitleTextMod(size: 20))
                if goal != 0 {
                    Button {
                        showSheet = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
            
            if let goal {
                if goal != 0 {
                    SingleRingProgress(progress: progress, current: current, goal: goal, small: false)
                    Text(motivationalMessage)
                        .font(.footnote)
                }
                else {
                    VStack(spacing: 8) {
                        Image(systemName: "target")
                            .font(.title)
                            .foregroundColor(.terracottaDarkIcons)
                        Text("Set your reading goal for 2025")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                        Button("Get Started") {
                            showSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .modifier(ChallengesBlockMod())
        .sheet(isPresented: $showSheet) {
            goalSetterSheetView(yChall: yChall, mChall: nil, tempGoal: $tempGoal, showSheet: $showSheet, goalName: "Set your reading goal for 2025")
                .presentationDetents([.fraction(0.25), .medium])
                .presentationDragIndicator(.visible)
        }
    }
}

struct MonthlyGoalView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var context
    
    var mChall: MonthlyReadingChallenge?
    
    @State private var showSheet: Bool = false
    @State private var tempGoal = ""
    
    var goal: Int? {
        mChall?.goal
    }
    
    var current: Int {
        mChall?.booksFinished ?? 0
    }
    
    var progress: Double {
        guard let goal, goal > 0 else { return 0 }
        return Double(current) / Double(goal)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: goal == nil ? 0 : 25) {
            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.terracotta)
                    .frame(width: 4, height: 20)
                Text("\(Date.now.formatted(.dateTime.month(.wide))) Goal")
                    .modifier(TitleTextMod(size: 18))
                
                if goal != 0 {
                    Button {
                        showSheet = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
            
            if let goal {
                if goal != 0 {
                    SingleRingProgress(progress: progress, current: current, goal: goal, small: true)
                } else {
                    VStack(spacing: 8) {
                        Text("Set your goal for this month!")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                        Button("Get Started") {
                            showSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .modifier(ChallengesBlockMod())
        .sheet(isPresented: $showSheet) {
            goalSetterSheetView(yChall: nil, mChall: mChall, tempGoal: $tempGoal, showSheet: $showSheet, goalName: "Set your goal for this month")
                .presentationDetents([.fraction(0.25), .medium])
                .presentationDragIndicator(.visible)
        }
    }
}

struct goalSetterSheetView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var context
    @StateObject private var auth = AuthManager()
    //var goal: Int
    var yChall: YearlyReadingChallenge?
    var mChall: MonthlyReadingChallenge?
    @Binding var tempGoal: String
    @Binding var showSheet: Bool
    var goalName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(goalName)
                .font(.headline)
                .padding(.top, 30)
            TextField("Books you want to read", text: $tempGoal)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.9))
                )
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .keyboardType(.numberPad)
                .padding(.horizontal)
            
            Button("Save") {
                if let newGoal = Int(tempGoal), newGoal > 0 {
                    if let yChall = yChall {
                        yChall.goal = newGoal
                        print("newGoal: \(newGoal) \n")
                        print("ychall.goal: \(yChall.goal)")
                    } else if let mChall = mChall {
                        mChall.goal = newGoal
                    }
                    try? context.save()
                    do {
                        let books = try context.fetch(FetchDescriptor<SavedBook>())
                        StatsManager.shared.updateStats(using: books, in: context, uid: auth.uid)
                    } catch {
                        print("❌ Failed to update stats: \(error)")
                    }
                    showSheet = false
                    tempGoal = ""
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(Color.terracotta)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            //.buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
        .padding(.top, 30)
        .onAppear {
            if let yChall = yChall {
                tempGoal = "\(yChall.goal)"
            } else if let mChall = mChall {
                tempGoal = "\(mChall.goal)"
            }
        }
    }
}

struct StreakTrackerView: View {
    var months: Int
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.terracotta)
                    .frame(width: 4, height: 20)
                Text("Reading Streak")
                    .modifier(TitleTextMod(size: 16))
                
            }
            Text("You've completed your monthly reading challenge for \(months) months!")
                .minimumScaleFactor(0.6)
        }
        .modifier(ChallengesBlockMod())
    }
}





struct LevelSectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var context
    @Query var globalStats: [GlobalReadingStats]

    @Binding var showInfoLevelSheet: Bool

    let xpPerLevel = 100

    var currentXP: Int {
        globalStats.first?.totalXP ?? 0
    }

    var currentLevel: Int {
        currentXP / xpPerLevel
    }

    var xpToNextLevel: Int {
        (currentLevel + 1) * xpPerLevel
    }

    var progress: Double {
        Double(currentXP % xpPerLevel) / Double(xpPerLevel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.terracotta)
                    .frame(width: 4, height: 20)
                Spacer()
                Text("Your Level")
                    .modifier(TitleTextMod(size: 20))
                Button {
                    showInfoLevelSheet.toggle()
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(.white)
                }
            }

            HStack {
                Text("Level \(currentLevel)")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("\(currentXP) / \(xpToNextLevel) XP")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .terracotta))
                .scaleEffect(x: 1, y: 3, anchor: .center)
        }
        .padding(.top, 8)
        .modifier(ChallengesBlockMod())
    }
}

struct BadgesSectionView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NavigationLink(destination: AchievementsView()
            ) {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.terracotta)
                        .frame(width: 4, height: 20)
                    
                    Text("Achievements")
                        .modifier(TitleTextMod(size: 20))
                    Image(systemName: "chevron.right")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    BadgeView(icon: "📘", title: "Bookworm\n10 Books", earned: true)
                    BadgeView(icon: "💥", title: "Reading Machine\n50 Books")
                    BadgeView(icon: "👑", title: "Legendary Reader\n100 Books")
                    BadgeView(icon: "👑", title: "Legendary Reader\n100 Books")
                    BadgeView(icon: "👑", title: "Legendary Reader\n100 Books")
                }
            }
        }
        .modifier(ChallengesBlockMod())
    }
}









struct StatsSectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var context
    @Query var globalStats: [GlobalReadingStats]

    var stats: [(String, Int)] {
        guard let stats = globalStats.first else { return [] }
        return [
            ("Books\nFinished", stats.totalBooksFinished),
            ("Pages\nRead", stats.totalPagesRead),
            ("Longest\nBook", stats.longestBookRead),
            ("Best\nYear", stats.mostBooksReadInAYear),
            ("Best\nMonth", stats.mostBooksReadInAMonth)
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.terracotta)
                    .frame(width: 4, height: 20)

                Text("Stats")
                    .modifier(TitleTextMod(size: 20))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(stats, id: \.0) { title, value in
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(Color.terracotta)
                                    .frame(width: 60, height: 60)
                                Text("\(value)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Text(title)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .frame(width: 70)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .modifier(ChallengesBlockMod())
        /*.onAppear {
            if globalStats.isEmpty {
                let stats = GlobalReadingStats()
                context.insert(stats)
                try? context.save()
                print("✅ GlobalReadingStats initialized")
            }
        }*/
    }
}









struct BadgeView: View {
    var icon: String
    var title: String
    var earned: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.largeTitle)
                .padding()
                .background(earned ? Color.terracotta.opacity(0.2) : Color.gray.opacity(0.1))
                .clipShape(Circle())
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80)
    }
}

struct SingleRingProgress: View {
    @Environment(\.colorScheme) var colorScheme
    var progress: Double
    let lineWIdthSmall: CGFloat = 10
    let lineWidth: CGFloat = 14
    var current: Int
    var goal: Int?
    var small: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: small ? lineWIdthSmall : lineWidth)
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    Color.terracotta,
                    style: StrokeStyle(lineWidth: small ? lineWIdthSmall : lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            VStack {
                Text("\(current)")
                    .font(.system(size: small ? 16 : 24, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                if let goal {
                    Text("of \(goal)")
                        .font(.system(size: small ? 10 : 14, weight: .light))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
        }
        .frame(width: small ? 60 : 100, height: small ? 60 : 100)
    }
}


struct ChallengesBlockMod: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, minHeight: 120 ,maxHeight: .infinity, alignment: .top)
            .padding()
            .background(colorScheme == .dark ? Color.backgroundColorDark2.opacity(0.8) : Color.backgroundColorLight.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct TitleTextMod: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var size: CGFloat
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: .semibold, design: .serif))
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}


struct LevelInfoSheetView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Level System Info")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 30)
                .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: 12) {
                Label("1 XP for every 10 pages read", systemImage: "book.fill")
                Label("25 XP for completing a monthly challenge", systemImage: "calendar")
                Label("100 XP for completing the yearly challenge", systemImage: "trophy.fill")
                Label("Bonus XP for reading long books", systemImage: "sparkles")
            }
            .font(.subheadline)
            .padding(.horizontal)

            //Spacer()

            Text("📚 Keep reading to level up!")
                .font(.callout)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        }
        .padding()
    }
}

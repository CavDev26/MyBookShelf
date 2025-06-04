import SwiftUI

struct ChallengesView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var refreshID = UUID()
    @AppStorage("readingGoal2025") private var readingGoal: Int?
    @AppStorage("monthlyGoal") private var monthlyGoal: Int?
    
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    TopNavBar {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        Image("MyIcon")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text("Challenges")
                            .padding(.leading, -10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom("Baskerville-SemiBoldItalic", size: 20))
                        Button {
                            readingGoal = nil
                            monthlyGoal = nil
                            refreshID = UUID() // Forces view reload
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    
                    ScrollView {
                        VStack(spacing: 30) {
                            ReadingChallengeView(goal: $readingGoal, current: 18)
                            HStack(alignment: .top, spacing: 16) {
                                MonthlyGoalView(current: 1, goal: $monthlyGoal)
                                    .frame(maxWidth: .infinity, minHeight: 120, maxHeight: .infinity)
                                StreakTrackerView(days: 5)
                                    .frame(maxWidth: .infinity, minHeight: 120, maxHeight: .infinity)
                            }
                            .frame(height: 120)
                            BadgesSectionView()
                                .frame(maxWidth: .infinity)
                            StatsSectionView()
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ReadingChallengeView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var goal: Int?
    var current: Int
    
    @State private var showSheet = false
    @State private var tempGoal = ""
    
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
                Text("2025 Reading Challenge")
                    .modifier(TitleTextMod(size: 20))
                if(goal != nil) {
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
                SingleRingProgress(progress: progress, current: current, goal: goal, small: false)
                Text(motivationalMessage)
                    .font(.footnote)
            } else {
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
        .modifier(ChallengesBlockMod())
        .sheet(isPresented: $showSheet) {
            goalSetterSheetView(goal: $goal, tempGoal: $tempGoal, showSheet: $showSheet, goalName: "Set your reading goal for 2025")
                .presentationDetents([.fraction(0.25), .medium])
                .presentationDragIndicator(.visible)
        }
    }
}

struct MonthlyGoalView: View {
    @Environment(\.colorScheme) var colorScheme
    var current: Int
    @Binding var goal: Int?
    @State var showSheet: Bool = false
    @State private var tempGoal = ""
    
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
                Text("June Goal")
                    .modifier(TitleTextMod(size: 18))
                
                if(goal != nil) {
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
                SingleRingProgress(progress: progress, current: current, goal: goal, small: true)
            }else {
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
        .modifier(ChallengesBlockMod())
        .sheet(isPresented: $showSheet) {
            goalSetterSheetView(goal: $goal, tempGoal: $tempGoal, showSheet: $showSheet, goalName: "Set your goal for this month")
                .presentationDetents([.fraction(0.25), .medium])
                .presentationDragIndicator(.visible)
        }
    }
}

struct StreakTrackerView: View {
    var days: Int
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.terracotta)
                    .frame(width: 4, height: 20)
                Text("Reading Streak")
                    .modifier(TitleTextMod(size: 18))
                
            }
            Text("You've read for \(days) days in a row!")
                .font(.caption)
        }
        .modifier(ChallengesBlockMod())
    }
}

struct BadgesSectionView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            NavigationLink(destination: PlaceHolderView()
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
                    NavigationLink(destination: PlaceHolderView()
                    ){
                        BadgeView(icon: "📘", title: "See all achievements")
                    }
                }
            }
        }
        .modifier(ChallengesBlockMod())
    }
}


struct StatsSectionView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            NavigationLink(destination: PlaceHolderView()
            ) {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.terracotta)
                        .frame(width: 4, height: 20)
                    
                    Text("Stats")
                        .modifier(TitleTextMod(size: 20))
                    Image(systemName: "chevron.right")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    
                    /*NavigationLink(destination: PlaceHolderView()
                    ){
                        Text("See all your stats")
                    }*/
                }
            }
        }
        .modifier(ChallengesBlockMod())
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

struct goalSetterSheetView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var goal: Int?
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
                    goal = newGoal
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
            if let goal {
                tempGoal = "\(goal)"
            }
        }
    }
}

#Preview {
    ChallengesView()
}

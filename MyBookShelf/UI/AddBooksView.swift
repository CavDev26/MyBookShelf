
import SwiftUI

struct AddBooksView: View {
    @StateObject private var vm = ViewModel()
    @Environment(\.colorScheme) var colorScheme

    //@State private var searchText: String = ""
    let columnCount: Int = 3
    let gridSpacing: CGFloat = -20.0
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(colorScheme == .dark ? vm.backgroundColorDark : vm.backgroundColorLight)
                    .ignoresSafeArea()
                    .opacity(colorScheme == .dark ? 1 : 0.5)
                VStack {
                    HStack{
                        ScanSearchBarView()
                            .padding(.bottom)
                            .padding(.top)
                            .padding(.horizontal)
                            .background {
                                Color(colorScheme == .dark ? vm.backgroundColorDark2 : vm.backgroundColorLight)
                                    .ignoresSafeArea()
                            }
                    }
                    .frame(width: .infinity, height: 50)

                    ScrollView(.vertical) {
                        Text("Discover by genre")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top)
                        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: gridSpacing), count: columnCount), spacing: gridSpacing) {
                            ForEach (0..<6) { i in
                                RoundedRectangle(cornerSize: .zero).frame(width: 100, height: 100).padding()
                            }
                        }
                        Text("Discover top picks")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach (0..<6) { i in
                                    RoundedRectangle(cornerSize: .zero).frame(width: 100, height: 100).padding()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


#Preview {
    AddBooksView()
}

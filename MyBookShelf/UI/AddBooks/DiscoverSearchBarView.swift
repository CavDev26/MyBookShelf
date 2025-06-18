import SwiftUI
import SwiftUICore

struct DiscoverSearchBarView: View {
    //@Binding var searchText: String
    @Binding var isSearching: Bool
    @ObservedObject var viewModel: CombinedGenreSearchViewModel
    @Binding var scanview: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var lastSearchText: String = ""

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(colorScheme == .dark ? .white : .black)

                ZStack(alignment: .trailing) {
                    
                    TextField("Search", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: viewModel.searchText) {
                            withAnimation(.easeInOut) {
                                isSearching = !viewModel.searchText.isEmpty
                            }
                        }
                    
                    /*TextField("Search", text: $searchText)
                        .textFieldStyle(.plain)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: searchText) { newValue in
                            withAnimation(.easeInOut) {
                                isSearching = !newValue.isEmpty
                            }

                            if !newValue.isEmpty && newValue != lastSearchText {
                                viewModel.searchBooks(query: newValue, reset: true)
                                lastSearchText = newValue
                            }
                        }*/
                    
                    
                    
                    
                    

                    /*if !searchText.isEmpty {
                        Image(systemName: "x.circle")
                            .padding(.trailing, 10)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                            .onTapGesture {
                                withAnimation {
                                    searchText = ""
                                    lastSearchText = ""
                                    viewModel.searchResults = []
                                    isSearching = false
                                }
                            }
                    }*/
                }
                .animation(.easeInOut(duration: 0.25), value: viewModel.searchText.isEmpty)
                NavigationLink(
                    destination: ScanView(searchText: $viewModel.searchText, lastSearchText: lastSearchText)
                        .id(UUID()),
                    isActive: $scanview
                ) {
                    Image(systemName: "barcode.viewfinder")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .onTapGesture {
                            scanview.toggle()
                        }
                }
            }
            .padding(10)
            .frame(height: 44)
            .frame(maxWidth: isSearching ? .infinity : .infinity, alignment: .leading)
            .background(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
            .cornerRadius(22)
            .animation(.easeInOut(duration: 0.3), value: isSearching)

            if isSearching {
                Button {
                    withAnimation {
                        viewModel.searchText = ""
                        lastSearchText = ""
                        isSearching = false
                        viewModel.searchResults = []
                        UIApplication.shared.endEditing()
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.terracotta)
                        .overlay {
                            Text("Cancel")
                                .foregroundColor(.white)
                        }
                        .frame(width: 70, height: 30)
                        .shadow(radius: 8)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isSearching)
    }
}

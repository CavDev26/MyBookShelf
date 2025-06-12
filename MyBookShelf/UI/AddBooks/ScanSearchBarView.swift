import SwiftUI

struct ScanSearchBarView: View {
    var scan: Bool
    @Environment(\.colorScheme) var colorScheme
    @Binding var searchText: String
    @State var navigated = false
    @State var scanview = false
    @State var searchInLibrary: Bool
    @StateObject private var viewModel = CombinedGenreSearchViewModel()

    
    var body: some View {
        
        
        /*HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.black)

            TextField("Search your books...", text: $vm.searchText)
                .textFieldStyle(.plain)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .overlay(
                    Image(systemName: "x.circle")
                        .padding()
                        .offset(x: 10)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .opacity(searchText.isEmpty ? 0.0 : 1.0)
                        .onTapGesture {
                            UIApplication.shared.endEditing()
                            searchText = ""
                        }, alignment: .trailing
                )
            if (scan) {
                Image(systemName: "barcode.viewfinder")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                //.opacity(searchText.isEmpty ? 1.0 : 0.0)
                    .onTapGesture {
                        scanview.toggle()
                    }
                NavigationLink("", destination: ScanView(), isActive: $scanview)
            }
            
        }
        .padding(10)
        .frame(height: 44)
        .background(vm.lightColorApp)
        .cornerRadius(22)
        */
        
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                TextField(!searchInLibrary ? "Search" : "Search your books...", text: $searchText)
                    .textFieldStyle(.plain)
                    .autocapitalization(.none)
                //.foregroundColor(.black)
                    .disableAutocorrection(true)
                    .overlay(
                        Image(systemName: "x.circle")
                            .padding()
                            .offset(x: 10)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .opacity(searchText.isEmpty ? 0.0 : 1.0)
                            .onTapGesture {
                                UIApplication.shared.endEditing()
                                searchText = ""
                            }, alignment: .trailing
                    )
                if (scan) {
                    Image(systemName: "barcode.viewfinder")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    //.opacity(searchText.isEmpty ? 1.0 : 0.0)
                        .onTapGesture {
                            scanview.toggle()
                        }
                    //NavigationLink("", destination: ScanView(), isActive: $scanview)
                }
            }
            //.font(.headline)
            .padding(10)
            .frame(height: 44)
            .background(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
            .cornerRadius(22)
        }
        
        /*.background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.gray).opacity(scan ? 0.6 : 1.0)
                .shadow(color: .black.opacity(0.50), radius: 5, x: 0, y: 0)
                .frame(width: .infinity, height: 40)
        )*/
    }
}

#Preview {
    @Previewable @State var searchText: String = ""
    ScanSearchBarView(scan: true, searchText: $searchText, searchInLibrary: false)
}

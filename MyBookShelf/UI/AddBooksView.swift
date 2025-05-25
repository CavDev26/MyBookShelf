
import SwiftUI

struct AddBooksView: View {
    //@EnvironmentObject private var vm: ViewModel
    @State private var searchText: String = ""
    

    
    var body: some View {
        
        
        ScanSearchBarView()
            /*.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10).fill(.blue).opacity(0.5).frame(width: 300, height: 30).padding(-40)
                            TextField("Search", text: $searchText)
                                .font(.system(size:  20))
                                .textFieldStyle(.plain)
                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        }
                                    
                        Button(action: {
                            print("-----> Button pressed")
                            // ...
                        }) {
                            Image(systemName: "barcode.viewfinder")
                        }
                    }
                    .frame(width: 300, height: 26) // adjust the size to yourpurpose
                }
            }*/
            
            
            /*.toolbar {
                ToolbarItem {
                    Button(action: {
                    }) {
                        Label("Add books", systemImage: "barcode.viewfinder")
                    }
                }
            }.searchable(text: $searchText)*/
        }
    }


#Preview {
    AddBooksView()
}

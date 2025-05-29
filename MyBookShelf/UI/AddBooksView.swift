
import SwiftUI

struct AddBooksView: View {
    //@EnvironmentObject private var vm: ViewModel
    //@State private var searchText: String = ""
    let columnCount: Int = 3
    let gridSpacing: CGFloat = -20.0
    
    var body: some View {
        ZStack(alignment: .top){
            NavigationStack {
                ScanSearchBarView().padding()
                ScrollView(.vertical) {
                    Text("Discover by genre")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
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
            
                
                
                //NavigationStack() {
                /*HStack (){
                 Image("MyIcon").resizable().frame(width: 50, height:50).padding(.leading)
                 Text("MyBookShelf").frame(maxWidth: .infinity, alignment:.leading).font(.custom("Baskerville-SemiBoldItalic", size: 20))
                 }*/
                /*ScrollView(.vertical){
                 Text("prova")
                 }*/
                //}
                
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
    }
}


#Preview {
    AddBooksView()
}

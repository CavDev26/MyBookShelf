//
//  SearchBarView.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 26/05/25.
//

import SwiftUI

struct ScanSearchBarView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State var searchText: String = ""
    @State var navigated = false
    @State var scanview = false

    
    var body: some View {
        //NavigationView{
            HStack{
                Image(systemName: "magnifyingglass")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                TextField("Search", text: $searchText)
                    .foregroundColor(.black)
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
                
                Image(systemName: "barcode.viewfinder")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    //.opacity(searchText.isEmpty ? 1.0 : 0.0)
                    .onTapGesture {
                        scanview.toggle()
                    }
                NavigationLink("", destination: ScanView(), isActive: $scanview)
            }
            .font(.headline)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.gray).opacity(0.6)
                    .shadow(color: .black.opacity(0.50), radius: 5, x: 0, y: 0)
                    .frame(width: .infinity, height: 40)
            )
        //}
    }
}

#Preview {
    ScanSearchBarView()
}

//
//  BlamkBookPlaceHolderView.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 31/05/25.
//

import SwiftUI

struct BlankBookPlaceHolderView : View {
    @StateObject private var vm = ViewModel()
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            NavigationLink(
                destination: PlaceHolderView()
            ) {
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(vm.backgroundColorLight)
                    
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.white)
                }
            }
        }
    }
}

#Preview {
    BlankBookPlaceHolderView()
}

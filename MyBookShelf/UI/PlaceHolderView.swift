//
//  PlaceHolderView.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 31/05/25.
//

import SwiftUI

struct PlaceHolderView: View {
    var body: some View {
        Text("Questa è un view placeholder; chissà dove ti porterà!")
    }
}


struct AnimatedButtonView: View {
    @State private var isExpanded = false

    var body: some View {
        HStack {
            // Bottone "Select" che scompare quando isExpanded è true
            if !isExpanded {
                Button("Select") {
                    print("Select tapped")
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }

            Spacer()

            // Bottone principale
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "magnifyingglass")

                    if isExpanded {
                        Text("Search")
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal, isExpanded ? 16 : 12)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(radius: 4)
            }
        }
        .padding()
        .animation(.easeInOut, value: isExpanded)
    }
}

#Preview {
    AnimatedButtonView()
}

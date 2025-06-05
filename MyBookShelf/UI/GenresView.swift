//
//  GenresView.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 05/06/25.
//

import SwiftUI


struct GenresView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    let genres = ["Fantasy", "Sci-Fi", "Mystery", "Romance", "Historical", "Thriller", "Horror"]

    var body: some View {
        
        NavigationStack {
            ZStack(alignment: .top) {
                Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                    .ignoresSafeArea()
                VStack {
                    TopNavBar {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    ScrollView {
                        VStack(spacing: 1) {
                            ForEach(genres, id: \.self) { genre in
                                NavigationLink(destination: PlaceHolderView()) {
                                    HStack {
                                        Text(genre)
                                            .font(.system(size: 17, weight: .regular, design: .serif))
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.backgroundColorLight)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    GenresView()
}

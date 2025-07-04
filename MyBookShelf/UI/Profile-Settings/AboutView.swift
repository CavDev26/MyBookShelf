//
//  AboutView.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 04/07/25.
//
import SwiftUI

struct AboutView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Spacer()
                
                Image("MyIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Text("MyBookShelf © 2025")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text("Version \(appVersion)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                VStack(spacing: 4) {
                    Text("Developed by Lorenzo Cavallucci")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text("All rights reserved. Mock trademark ℗")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom)
            }
            .padding()
        }
        .customNavigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

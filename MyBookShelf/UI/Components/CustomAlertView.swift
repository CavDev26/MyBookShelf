//
//  CustomAlertView.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 04/07/25.
//

import Foundation
import SwiftUI

struct CustomAlertView: View {
    let message: String
    let success: Bool
    let onDismiss: () -> Void

    @State private var showContent = false
    @State private var animateIcon = false

    var body: some View {
        ZStack {
            Color.black.opacity(showContent ? 0.4 : 0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.1), value: showContent)
                .onTapGesture {
                    dismissAlert()
                }

            if showContent {
                VStack(spacing: 16) {
                    Image(systemName: success ? "checkmark.circle.fill" : "x.circle")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(success ? .green : .red)
                        .scaleEffect(animateIcon ? 1.3 : 0.5)
                        .opacity(animateIcon ? 1 : 0)
                        .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: animateIcon)

                    Text(message)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button(action: {
                        dismissAlert()
                    }) {
                        Text("OK")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.terracotta)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground)))
                .frame(maxWidth: 300)
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.1, dampingFraction: 0.65), value: showContent)
            }
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateIcon = true
            }
        }
    }

    private func dismissAlert() {
        withAnimation {
            animateIcon = false
            showContent = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}

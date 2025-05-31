//
//  Utils.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 30/05/25.
//

import SwiftUICore

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        }
    }
}


struct SizeCalculator: ViewModifier {
    @Binding var size: CGSize
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear // we just want the reader to get triggered, so let's use an empty color
                        .onAppear {
                            size = proxy.size
                        }
                }
            )
    }
}

extension View {
    func saveSize(in size: Binding<CGSize>) -> some View {
        modifier(SizeCalculator(size: size))
    }
}


struct TopNavBar<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var vm = ViewModel()
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack(spacing: 12) {
            content
        }
        .padding(.horizontal)
        .padding(.bottom)
        .frame(maxWidth: .infinity)
        .frame(height: 65)
        .background {
            Color(colorScheme == .dark ? vm.backgroundColorDark2 : vm.backgroundColorLight)
                .ignoresSafeArea(edges: .top)
        }
    }
}

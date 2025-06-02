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
    //@StateObject private var vm = ViewModel()
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
            Color(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                .ignoresSafeArea(edges: .top)
        }
    }
}

extension Color {
    static let terracotta = Color(red: 200/255, green: 120/255, blue: 60/255)
    static let readingColor = Color(red: 130/255, green: 180/255, blue: 230/255)
    static let readColor = Color(red: 142/255, green: 197/255, blue: 160/255)
    static let unreadColor = Color(red: 216/255, green: 190/255, blue: 168/255)
    static let backgroundColorLight = Color(red: 0.8745098039215686, green: 0.8313725490196079, blue: 0.7450980392156863)
    static let backgroundColorDark = Color(red: 0.4470588235294118, green: 0.4235294117647059, blue: 0.3764705882352941)
    static let backgroundColorDark2 = Color(red: 0.2784313725490196, green: 0.25882352941176473, blue: 0.21568627450980393)
    static let lightColorApp = Color(red: 244/255, green: 238/255, blue: 224/255)
    static let peachColorIcons = Color(red: 200/255, green: 120/255, blue: 60/255)
    
}

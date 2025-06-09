//
//  Utils.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 30/05/25.
//

import SwiftUICore
import UIKit
import SwiftUI

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

struct GlossyOverlay: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.0),
                            .white.opacity(0.15), // 👈 meno invasivo
                            .white.opacity(0.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: geo.size.width * 0.5) // 👈 più stretto
                .rotationEffect(.degrees(25))
                .offset(x: animate ? geo.size.width : -geo.size.width)
                .animation(.linear(duration: 2.5), value: animate)
                //.repeatForever(autoreverses: false), value: animate)
                .onAppear { animate = true }
        }
        .blendMode(.screen) // 👈 riflesso più naturale
        .clipped()
        .allowsHitTesting(false)
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
    static let terracottaDarkIcons = Color(red: 180/255, green: 100/255, blue: 50/255) // #B46432
    
}

extension UIImage {
    func suitableBackgroundColor() -> Color {
        
        
        
        guard let cgImage = self.cgImage else { return .black }

        let ciImage = CIImage(cgImage: cgImage)
        let context = CIContext()
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: ciImage]),
              let outputImage = filter.outputImage else { return .black }

        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())

        // Calcolo del colore medio
        let red = Double(bitmap[0]) / 255
        let green = Double(bitmap[1]) / 255
        let blue = Double(bitmap[2]) / 255

        // Converti in luminosità percepita
        let brightness = 0.299 * red + 0.587 * green + 0.114 * blue

        // Se troppo chiaro, scurisci artificialmente
        if brightness > 0.7 {
            return Color(red: red * 0.4, green: green * 0.4, blue: blue * 0.4)
        }

        // Se già scuro, mantienilo
        return Color(red: red, green: green, blue: blue)
    }
}
extension Image {
    func asUIImage() -> UIImage? {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let image = child.value as? UIImage {
                return image
            }
        }
        return nil
    }
}







struct CustomNavigationTitleModifier: ViewModifier {
    var title: String
    var color: Color
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("\(title)")

                        .font(.system(size: 18, weight: .semibold, design: .serif))
                }
            }
            .navigationTitle("\(title)")
            .toolbarBackground(Color(colorScheme == .dark ? Color.backgroundColorDark : Color.backgroundColorLight)
                .opacity(1) // se si abbassa, rimane l'effetto glossy sotto
            )
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

extension View {
    func customNavigationTitle(_ title: String, color: Color = .white) -> some View {
        self.modifier(CustomNavigationTitleModifier(title: title, color: color))
    }
}

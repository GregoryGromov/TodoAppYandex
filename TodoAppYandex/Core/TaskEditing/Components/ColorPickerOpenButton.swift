import SwiftUI

struct ColorPickerOpenButton: View {
    let color: Color
    let diameter: Double

    var body: some View {
        ZStack {
            palette
                .frame(width: diameter)
            Circle()
                .fill(.white)
                .frame(width: diameter * 0.85)
            Circle()
                .fill(color)
                .frame(width: diameter * 0.65)
        }
    }

    private var palette: some View {
        AngularGradient(gradient: Gradient(colors: [
            Color(hue: 1.0, saturation: 1, brightness: 1),
            Color(hue: 0.9, saturation: 1, brightness: 1),
            Color(hue: 0.8, saturation: 1, brightness: 1),
            Color(hue: 0.7, saturation: 1, brightness: 1),
            Color(hue: 0.6, saturation: 1, brightness: 1),
            Color(hue: 0.5, saturation: 1, brightness: 1),
            Color(hue: 0.4, saturation: 1, brightness: 1),
            Color(hue: 0.3, saturation: 1, brightness: 1),
            Color(hue: 0.2, saturation: 1, brightness: 1),
            Color(hue: 0.1, saturation: 1, brightness: 1),
            Color(hue: 0.0, saturation: 1, brightness: 1)
        ]), center: .center)
        .clipShape(Circle())
    }
}

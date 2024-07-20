import SwiftUI

private enum LayoutConstants {
    static let sideLenght: CGFloat = 44
    static let imageSize: CGFloat = 22
    static let shadowRadius: CGFloat = 20
    static let shadowX: CGFloat = 0
    static let shadowY: CGFloat = 8
}

struct AddNewItemButton: View {

    var action: (() -> Void)?

    var body: some View {
        Button {
            action?()
        } label: {
            ImageCollection.plus
                .font(.system(size: LayoutConstants.imageSize, weight: .bold))
                .foregroundColor(.white)
                .frame(
                    width: LayoutConstants.sideLenght,
                    height: LayoutConstants.sideLenght
                )
                .background(.blue)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .shadow(
            color: .gray,
            radius: LayoutConstants.shadowRadius,
            x: LayoutConstants.shadowX,
            y: LayoutConstants.shadowY
        )
    }
}

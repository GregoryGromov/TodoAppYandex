import SwiftUI

private enum LayoutConstants {
    static let textFieldTopPadding: CGFloat = 10
    static let textFieldBottomPadding: CGFloat = -10
    static let minHeight: CGFloat = 120
    static let lineCornerRadius: CGFloat = 4
    static let lineWidth: CGFloat = 4
}

struct TextFieldCell: View {
    @Binding var text: String
    @Binding var color: Color

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            VStack {
                textField
                Spacer()
            }
            colorLine
        }
        .background(.white)
        .frame(minHeight: LayoutConstants.minHeight)
        .onTapGesture {
            isFocused = true
        }
    }

    private var textField: some View {
        TextField("Что надо сделать?", text: $text, axis: .vertical)
            .focused($isFocused)
            .padding(.top, LayoutConstants.textFieldTopPadding)
            .padding(.bottom, LayoutConstants.textFieldBottomPadding)
    }

    private var colorLine: some View {
        RoundedRectangle(cornerRadius: LayoutConstants.lineCornerRadius)
            .fill(color)
            .frame(width: LayoutConstants.lineWidth)
            .padding([.top, .bottom])
    }
}

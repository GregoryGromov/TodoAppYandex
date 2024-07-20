import SwiftUI

private enum LayoutConstants {
    static let horizontalSpacing: CGFloat = 2

    static let todoColorLineCornerRadius: CGFloat = 5
    static let todoColorLineWidth: CGFloat = 4
    static let todoColorLineHeight: CGFloat = 26

    static let addTodoButtonBottomPadding: CGFloat = 45
}

struct TodoInfoLabel: View {
    let item: TodoItem

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: LayoutConstants.horizontalSpacing) {
                if item.importance == .important && !item.isDone {
                    ImageCollection.exclamationMark
                        .foregroundStyle(.red)
                        .fontWeight(.bold)
                }
                Text(item.text)
                    .strikethrough(item.isDone ? true : false)
                    .opacity(item.isDone ? 0.4 : 1) 
                Spacer()
                if let colorString = item.color {
                    RoundedRectangle(cornerRadius: LayoutConstants.todoColorLineCornerRadius)
                        .foregroundStyle(Color(hex: colorString))
                        .frame(width: LayoutConstants.todoColorLineWidth, height: LayoutConstants.todoColorLineHeight)
                }
            }

            if !item.isDone {
                if let deadline = item.deadline {
                    HStack(spacing: LayoutConstants.horizontalSpacing) {
                        ImageCollection.calendar
                        Text(deadline.dayMonth)
                        Spacer()
                    }
                    .opacity(0.4)
                    .font(.caption)
                }
            }
        }
        Spacer()
        ImageCollection.chevronRight
            .foregroundStyle(Color(.systemGray3))
    }
}

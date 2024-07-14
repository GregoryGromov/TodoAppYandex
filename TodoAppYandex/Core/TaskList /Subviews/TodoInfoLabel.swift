import SwiftUI

struct TodoInfoLabel: View {

    let item: TodoItem

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 2) {
                if item.importance == .important && !item.isDone {
                    ImageCollection.exclamationMark
                        .foregroundStyle(.red)
                        .fontWeight(.bold)
                }
                Text(item.text)
                    .strikethrough(item.isDone ? true : false)
                    .opacity(item.isDone ? 0.4 : 1)

                if let colorString = item.color {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(Color(hex: colorString))
                    //
                        .frame(width: 50, height: 5)
                }

            }

            if !item.isDone {
                if let deadline = item.deadline {
                    HStack(spacing: 2) {
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

import SwiftUI
import SwiftData

@Model
class TodoItemStoredModel {

    @Attribute(.unique) var id: String

    var text: String
    var importance: String
    var deadline: Date?
    var isDone: Bool

    var dateCreation: Date
    var dateChanging: Date?

    var color: String?

    init(
        id: String = UUID().uuidString,
        text: String,
        importance: String,
        deadline: Date? = nil,
        isDone: Bool,
        dateCreation: Date,
        dateChanging: Date? = nil,
        color: String? = nil
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone

        self.dateCreation = dateCreation
        self.dateChanging = dateChanging

        self.color = color
    }
}

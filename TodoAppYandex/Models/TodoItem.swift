import Foundation

struct TodoItem: Identifiable, Equatable {
    
    let id: String
    
    let text: String
    let importance: Importance
    let deadline: Date?
    var isDone: Bool
    
    let dateCreation: Date
    let dateChanging: Date?
    
    var color: String?
    
    

    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance,
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















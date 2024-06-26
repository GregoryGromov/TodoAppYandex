import Foundation

struct TodoItem: Identifiable, Equatable {
    
    let id: String
    
    let text: String
    let importance: Importance
    let deadline: Date?
    var isDone: Bool
    
    let dateCreation: Date
    let dateChanging: Date?
    
    
//    кастомный инициализатор необходим, так как нам нужно иметь возможность как вручную задавать id (напрмер, при распарсинге), так и автоматически
    init(id: String = UUID().uuidString, text: String, importance: Importance, deadline: Date? = nil, isDone: Bool, dateCreation: Date, dateChanging: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        
        self.dateCreation = dateCreation
        self.dateChanging = dateChanging
    }
}















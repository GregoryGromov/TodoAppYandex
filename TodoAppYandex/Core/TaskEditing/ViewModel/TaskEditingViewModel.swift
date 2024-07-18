import SwiftUI
import Combine

class TaskEditingViewModel: ObservableObject {

    @Published var mode: TodoEditMode

    let id: String
    let isDone: Bool
    let dateCreation: Date?

    @Published var text: String
    @Published var selectedImportance: Importance
    @Published var deadline: Date
    @Published var color: Color

    @Published var colorIsSet: Bool
    @Published var deadlineSet: Bool {
        didSet {
            if !deadlineSet {
                showCalendar = false
            }
        }
    }

    @Published var showCalendar: Bool
    @Published var showColorPicker: Bool
    
    @Published var isDirty = false // TODO: хранить в UserDefaults

    private var cancellables = Set<AnyCancellable>()

    init(mode: TodoEditMode, todoItem: TodoItem?) {
  
        self.mode = mode
        self.showCalendar = false
        self.showColorPicker = false

        if let oldTodoItem = todoItem {
            self.id = oldTodoItem.id
            self.isDone = oldTodoItem.isDone
            self.dateCreation = oldTodoItem.dateCreation

            self.text = oldTodoItem.text
            self.selectedImportance = oldTodoItem.importance

            if let color = oldTodoItem.color {
                self.color = Color(hex: color)
                self.colorIsSet = true
            } else {
                self.color = .white
                self.colorIsSet = false
            }

            if let deadline = oldTodoItem.deadline {
                self.deadline = deadline
                self.deadlineSet = true
            } else {
                self.deadline = Date().addingTimeInterval(86_400)
                self.deadlineSet = false
            }

        } else {
            self.id = UUID().uuidString
            self.isDone = false
            self.dateCreation = nil

            self.text = ""
            self.selectedImportance = .basic
            self.color = .white
            self.deadline = Date().addingTimeInterval(86_400)

            self.deadlineSet = false
            self.colorIsSet = false
        }
        
        FileCache.shared.$isDirty
            .sink { [weak self] isDirty in
                self?.isDirty = isDirty
            }
            .store(in: &cancellables)
    }

    func addTodoItem() {
        
        let newTodoItem = assembleTodoItem()
        
        FileCache.shared.addTodo(newTodoItem)
    }

    func editTodoItem() {
        let modifiedTodoItem = assembleTodoItem()
//        FileCache.shared.editTodoItem(modifiedTodoItem)
//        FileCache.shared.updateTodo(byId: modifiedTodoItem.id)
        FileCache.shared.editTodo(modifiedTodoItem)
    }
    

    private func assembleTodoItem() -> TodoItem {
        let deadline: Date? = deadlineSet ? deadline : nil
//        let dateChanging: Date? = (mode == .create) ? nil : Date()
        let dateChanging = Date()

        let colorHEX: String? = colorIsSet ? color.toHex() : nil
        let dateCreation: Date = dateCreation ?? Date()

        let todoItem = TodoItem(
            id: id,
            text: text,
            importance: selectedImportance,
            deadline: deadline,
            isDone: isDone,
            dateCreation: dateCreation,
            dateChanging: dateChanging,
            color: colorHEX
        )
        return todoItem
    }

    func getPickerPreview(for importance: Importance) -> some View {
        switch importance {
        case .low:
            return ImageCollection.arrowDown.eraseToAnyView()
        case .basic:
            return Text("нет").eraseToAnyView()
        case .important:
            return ImageCollection.exclamationMark.eraseToAnyView()
        }
    }
}

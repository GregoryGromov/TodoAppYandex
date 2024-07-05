import Foundation

class FileCache {
    
    @Published var todoItems: [TodoItem]
    
    static let shared = FileCache()
    
    init(todoItems: [TodoItem] = TodoItem.MOCK) {
        self.todoItems = todoItems
    }
    
    func getTodoItems() -> [TodoItem] {
        return todoItems
    }
    
    func addTodoItem(_ todoItem: TodoItem) {
        if noSameItem(withId: todoItem.id) {
            todoItems.append(todoItem)
        }
    }
    
    func switchIsDone(byId id: String) {
        for index in todoItems.indices {
            if todoItems[index].id == id {
                todoItems[index].isDone.toggle()
            }
        }
    }
    
    func deleteTodoItem(byId id: String) {
        for index in todoItems.indices {
            if todoItems[index].id == id {
                todoItems.remove(at: index)
                return
            }
        }
    }
    
    private func noSameItem(withId id: String) -> Bool {
        for item in todoItems {
            if item.id == id {
                return false
            }
        }
        return true
    }
    
    
    func saveTodoItemsToFile() throws {
        let arrayOfJSONs = todoItems.map { $0.json }
        
        do {
            try FileManagerService.shared.writeDataToFile(withName: "todoItems", data: arrayOfJSONs)
        } catch {
            print("Error saving todoItems to file, error: \(error)")
            throw error
        }
    }
    
    
    func getTodoItemsFromFile() throws {
        guard let data = FileManagerService.shared.readDataFromFile(withName: "todoItems") else { return }
        
        do {
            if let itemsAsJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                
                var todoItemsFromJSON = [TodoItem]()
                
                for itemAsJson in itemsAsJSON {
                    if let parsedTodoItem = TodoItem.parse(json: itemAsJson) {
                        todoItemsFromJSON.append(parsedTodoItem)
                    }
                }
                
                todoItems = todoItemsFromJSON
            }
        } catch {
            print("Ошибка при преобразовании Data в [[String: Any]]: \(error.localizedDescription)")
            throw error
        }
    }
}

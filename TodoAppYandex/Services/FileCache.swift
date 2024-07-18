import Foundation

class FileCache {

    @Published var todoItems: [TodoItem]
    @Published var currentRevision: Int

    static let shared = FileCache()
    
    let service = DefaultNetworkingService()

    init(todoItems: [TodoItem] = TodoItem.MOCK) {
//        self.todoItems = todoItems
        self.todoItems = []
        self.currentRevision = 1
    }
    
    func getTodo(byId id: String) -> TodoItem? {
        for todoItem in todoItems {
            if todoItem.id == id {
                return todoItem
            }
        }
        return nil
    }
    
    
//------------------------------->
    
    
    
    func refreshTodo(byId id: String) async throws {
        if let modifiedTodo = getTodo(byId: id) {
//            print("CurrentRevision:", currentRevision)
            do {
                let (_, revision) = try await service.updateElement(byId: modifiedTodo.id, with: modifiedTodo, revision: currentRevision)
                currentRevision = revision
            } catch {
                throw error
            }
        }
    }
    
    
    func updateServerData(with items: [TodoItem]) async throws {
        do {
            let (fromUpdateList, revision) = try await service.updateList(with: items, revision: 1)
            currentRevision = revision
            let (loadedTodoItems, revision2) = try await service.getList()
            await MainActor.run {
                self.currentRevision = revision2
                self.todoItems = loadedTodoItems
            }
        } catch {
            throw error
        }
    }
    
    
    func loadTodoItems() async throws {
        let (loadedTodoItems, revision)  = try await service.getList()
        await MainActor.run {
//            print("Revision в loadTodoItems:", loadTodoItems)
            currentRevision = revision
//            print("Установлена на:", currentRevision)
            todoItems = loadedTodoItems
            
        }
    }
    
    
//----------------------------------------<
    
    
    func getTodoItems() -> [TodoItem] {
        return todoItems
    }
    

    func addTodoItem(_ todoItem: TodoItem) {
        if noSameItem(withId: todoItem.id) {
            todoItems.append(todoItem)
        }
    }

    func editTodoItem(_ todoItem: TodoItem) {
        for index in todoItems.indices where todoItems[index].id == todoItem.id {
            todoItems[index] = todoItem
        }
    }

    func switchIsDone(byId id: String) {
        for index in todoItems.indices where todoItems[index].id == id {
            todoItems[index].isDone.toggle()
        }
    }

    func deleteTodoItem(byId id: String) {
        for index in todoItems.indices where todoItems[index].id == id {
            todoItems.remove(at: index)
            return
        }
    }

    private func noSameItem(withId id: String) -> Bool {
        for item in todoItems where item.id == id {
            return false
        }
        return true
    }

    func saveTodoItemsToFile() throws {
        let arrayOfJSONs = todoItems.map { $0.json }

        do {
            try FileManagerService.shared.writeDataToFile(withName: FileNames.todoItems, data: arrayOfJSONs)
        } catch {
            throw DataStorageError.savingToFileFailed
        }
    }

    func getTodoItemsFromFile() throws {
        guard let data = try FileManagerService.shared.readDataFromFile(withName: FileNames.todoItems) else { return }

        do {
            if let itemsAsJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {

                var todoItemsFromJSON = [TodoItem]()

                for itemAsJson in itemsAsJSON {
                    if let parsedTodoItem = try TodoItem.parse(json: itemAsJson) {
                        todoItemsFromJSON.append(parsedTodoItem)
                    }
                }

                todoItems = todoItemsFromJSON
            }
        } catch {
            throw DataStorageError.convertingDataFailed
        }
    }
}

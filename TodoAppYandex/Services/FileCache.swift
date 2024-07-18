import Foundation

class FileCache {

    @Published var todoItems: [TodoItem]
    @Published var currentRevision: Int
    @Published var isDirty = false

    static let shared = FileCache()
    
    let service = DefaultNetworkingService()

    init(todoItems: [TodoItem] = TodoItem.MOCK) {
        self.todoItems = []
        self.currentRevision = 1
    }
    
//    MARK: - Adding
    
    func addTodo(_ todoItem: TodoItem) {
        addTodoLocally(todoItem)

        Task {
            do {
                if isDirty {
                    try await synchronizeData()
                } else {
                    try await addTodoOnServer(todoItem)
                }
            } catch {
                await MainActor.run {
                    isDirty = true
                }
            }
        }
    }
    
    func addTodoLocally(_ todoItem: TodoItem) {
        if noSameItem(withId: todoItem.id) {
            todoItems.append(todoItem)
        }
    }
    
    func addTodoOnServer(_ todoItem: TodoItem) async throws {
        do {
            let (_, revision) = try await service.addElement(todoItem, revision: currentRevision)
            currentRevision = revision
        } catch {
            throw error
        }
    }
    
//    MARK: - Switching "isDone" propertie
    
    func switchIsDone(byId id: String) {
        switchIsDoneLocally(byId: id)
        updateTodo(byId: id)
    }
    
    func switchIsDoneLocally(byId id: String) {
        for index in todoItems.indices where todoItems[index].id == id {
            todoItems[index].isDone.toggle()
        }
    }
    
//    MARK: - Editing
    
    func editTodo(_ todoItem: TodoItem) {
        editTodoLocally(todoItem)
        updateTodo(byId: todoItem.id)
    }
    
    func editTodoLocally(_ todoItem: TodoItem) {
        for index in todoItems.indices where todoItems[index].id == todoItem.id {
            todoItems[index] = todoItem
        }
    }
    
//    MARK: - Updating
    
    func updateTodo(byId id: String) {
        if let updatedTodo = getTodo(byId: id) {
            Task {
                do {
                    if isDirty {
                        try await synchronizeData()
                    } else {
                        try await updateTodoOnServer(with: updatedTodo)
                    }
                } catch {
                    await MainActor.run {
                        isDirty = true
                    }
                }
            }
        }
    }
    
    func updateTodoOnServer(with updatedTodo: TodoItem) async throws {
        do {
            let (_, revision) = try await service.updateElement(byId: updatedTodo.id, with: updatedTodo, revision: currentRevision)
            currentRevision = revision
        } catch {
            throw error
        }
    }
    
//  MARK: - Synchronization
    
    private func synchronizeData() async throws {
        let todosWithUpdatedIDs = updateIDsOfList()
        
        try await updateServerData(with: todosWithUpdatedIDs)
        await MainActor.run {
            isDirty = false
        }
    }
    
    private func updateIDsOfList() -> [TodoItem] {
        return todoItems.map { todo -> TodoItem in
            var updatedTodo = todo
            updatedTodo.id = UUID().uuidString
            return updatedTodo
        }
    }
    
    private func updateServerData(with items: [TodoItem]) async throws {
        do {
            let (_, revision) = try await service.updateList(with: items, revision: 1)
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

// MARK: - Deletion
    
    func deleteTodo(byId id: String) {
        deleteTodoLocally(byId: id)
        
        Task {
            do {
                if isDirty {
                    try await synchronizeData()
                } else {
                    try await deleteTodoOnServer(byId: id)
                }
            } catch {
                await MainActor.run {
                    isDirty = true
                }
            }
        }
    }
    
    func deleteTodoLocally(byId id: String) {
        for index in todoItems.indices {
            if todoItems[index].id == id {
                todoItems.remove(at: index)
                return
            }
        }
    }
    
    private func deleteTodoOnServer(byId id: String) async throws {
        do {
            let (_, revision) = try await service.deleteElement(byId: id, revision: currentRevision)
            currentRevision = revision
        } catch {
            throw error
        }
    }
    
//  MARK: - Loading
    
    func loadTodoItems() async throws {
        let (loadedTodoItems, revision)  = try await service.getList()
        await MainActor.run {
            currentRevision = revision
            todoItems = loadedTodoItems
        }
    }

// MARK: - Local saving to file
    
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
    
//  MARK: - Utilities
    
    private func noSameItem(withId id: String) -> Bool {
        for item in todoItems where item.id == id {
            return false
        }
        return true
    }
    
    func getTodo(byId id: String) -> TodoItem? {
        for todoItem in todoItems {
            if todoItem.id == id {
                return todoItem
            }
        }
        return nil
    }
}

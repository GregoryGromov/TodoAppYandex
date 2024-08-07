import Foundation
import SwiftData

class FileCache {
    
    @Published var todoItems: [TodoItem]
    @Published var currentRevision: Int
    
    @Published var isDirty = false
    @Published var retryInProgress = false
    
    let service = DefaultNetworkingService()
    
    var modelContext: ModelContext?
    var modelContainer: ModelContainer?
    
    let emptyDescriptor = FetchDescriptor<TodoItemStoredModel>(predicate: nil)
    
    @MainActor
    init(todoItems: [TodoItem] = TodoItem.MOCK) {
        self.todoItems = []
        self.currentRevision = 1
        
        let inMemory = false
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
            let container = try ModelContainer(for: TodoItemStoredModel.self, configurations: configuration)
            modelContainer = container
            modelContext = container.mainContext
            modelContext?.autosaveEnabled = true
            
            fetch()
//            fetchAdditional(filter: .important, sort: .name)
        } catch {
            print(error)
        }
    }
    
    // MARK: - Delayed request utilities
    
    @Published var IDsOfActiveTasks = [String]()
    
    let minDelay: TimeInterval = 2
    let maxDelay: TimeInterval = 5
    let factor: Double = 1.5
    let jitter: Double = 0.05
    
    func randomInRange(min: Double, max: Double) -> Double {
        return Double.random(in: min...max)
    }
    
    func calculateNextDelay(currentDelay: TimeInterval) -> TimeInterval {
        let jitterValue = currentDelay * jitter
        let nextDelay = currentDelay * factor
        return min(maxDelay, max(minDelay, nextDelay + randomInRange(min: -jitterValue, max: jitterValue)))
    }
    
    private func addTaskID(_ id: String) {
        IDsOfActiveTasks.append(id)
    }
    
    private func deleteTaskID(_ id: String) {
        for index in IDsOfActiveTasks.indices {
            if IDsOfActiveTasks[index] == id {
                IDsOfActiveTasks.remove(at: index)
                return
            }
        }
    }
    
    // MARK: - SwiftData
    
    enum FetchSort {
        case name
        case dateCreation
    }
    
    enum FetchFilter {
        case isDone
        case setDeadline
        case important
    }
    
    func fetchAdditional(filter: FetchFilter, sort: FetchSort) {
        guard let modelContext = modelContext else { return }
        
        let sortDescriptor: SortDescriptor<TodoItemStoredModel>
        switch sort {
        case .name:
            sortDescriptor = .init(\.text)
        case .dateCreation:
            sortDescriptor = .init(\.dateCreation)
        }
        
        let filterPredicate: Predicate<TodoItemStoredModel>
        switch filter {
        case .isDone:
            filterPredicate = #Predicate<TodoItemStoredModel> { todoItem in
                todoItem.isDone
            }
        case .setDeadline:
            filterPredicate = #Predicate<TodoItemStoredModel> { todoItem in
                todoItem.deadline != nil
            }
        case .important:
            filterPredicate = #Predicate<TodoItemStoredModel> { todoItem in
                todoItem.importance == "important"
            }
        }

        let fetchDescriptor = FetchDescriptor<TodoItemStoredModel>(
            predicate: filterPredicate,
            sortBy: [sortDescriptor]
        )
        do {
            let todoItemsSM = try modelContext.fetch(fetchDescriptor)
            self.todoItems = todoItemsSM.compactMap { convertToTodoItem(from: $0) }
        } catch {
            print(error)
        }
    }
    
    func fetch() {
        guard let modelContext = modelContext else { return }
        
        do {
            let todoItemsSM = try modelContext.fetch(emptyDescriptor)
            self.todoItems = todoItemsSM.compactMap { convertToTodoItem(from: $0) }
        } catch {
            print(error)
        }
    }
    
    func insert(_ todoItem: TodoItem) {
        guard let modelContext = modelContext else { return }
        
        let todoItemSM = convertToTodoItemStoredModel(from: todoItem)
        modelContext.insert(todoItemSM)
        
        update()
    }
    
    func delete(_ todoItem: TodoItem) {
        guard let modelContext = modelContext else { return }
        do {
            let todoItemSM = try getTodoItemSM(byId: todoItem.id)
            modelContext.delete(todoItemSM)
            
            update()
        } catch {
            print(error)
        }
    }
    
    func update(_ todoItem: TodoItem) {
        guard let modelContext = modelContext else { return }
        do {
            let todoItemSM = try getTodoItemSM(byId: todoItem.id)
            modelContext.delete(todoItemSM)
            
            let newTodoItemSM = convertToTodoItemStoredModel(from: todoItem)
            modelContext.insert(newTodoItemSM)
            
            update()
        } catch {
            print(error)
        }
    }
    
    func deleteTodoFromSwiftData(byId id: String) {
        if let todoItem = getTodo(byId: id) {
            delete(todoItem)
        }
    }
    
    func updateTodoItemInSwiftData(byID id: String) {
        switchIsDoneLocally(byId: id)
        if let todoItem = getTodo(byId: id) {
            update(todoItem)
        }
    }
    
    private func update() {
        save()
        fetch()
    }
    
    private func save() {
        guard let modelContext = modelContext else { return }
        do {
            try modelContext.save()
        } catch {
            print(error)
        }
    }

    private func convertToTodoItem(from model: TodoItemStoredModel) -> TodoItem? {
        guard let importance = Importance(rawValue: model.importance) else {
            return nil
        }
        return TodoItem(
            id: model.id,
            text: model.text,
            importance: importance,
            deadline: model.deadline,
            isDone: model.isDone,
            dateCreation: model.dateCreation,
            dateChanging: model.dateChanging,
            color: model.color
        )
    }

    private func convertToTodoItemStoredModel(from item: TodoItem) -> TodoItemStoredModel {
        return TodoItemStoredModel(
            id: item.id,
            text: item.text,
            importance: item.importance.rawValue,
            deadline: item.deadline,
            isDone: item.isDone,
            dateCreation: item.dateCreation,
            dateChanging: item.dateChanging,
            color: item.color
        )
    }
    
    private func getTodoItemSM(byId id: String) throws -> TodoItemStoredModel {
        guard let modelContext = modelContext else {
            throw DataStorageError.modelContextFailed
        }
        do {
            let todoItemsSM = try modelContext.fetch(emptyDescriptor)
            for todoItemSM in todoItemsSM {
                if todoItemSM.id == id {
                    return todoItemSM
                }
            }
        } catch {
            throw error
        }
        throw DataStorageError.unknownError
    }

    // MARK: - Adding

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

    private func addTodoLocally(_ todoItem: TodoItem) {
        if noSameItem(withId: todoItem.id) {
            todoItems.append(todoItem)
        }
    }

    private func addTodoOnServer(_ todoItem: TodoItem) async throws {
        do {
            let (_, revision) = try await service.addElement(todoItem, revision: currentRevision)
            currentRevision = revision
        } catch {
            throw error
        }
    }

    // MARK: - Switching "isDone" propertie

    func switchIsDone(byId id: String) {
        switchIsDoneLocally(byId: id)
        updateTodo(byId: id)
    }

    private func switchIsDoneLocally(byId id: String) {
        for index in todoItems.indices where todoItems[index].id == id {
            todoItems[index].isDone.toggle()
        }
    }

    // MARK: - Editing

    func editTodo(_ todoItem: TodoItem) {
        editTodoLocally(todoItem)
        updateTodo(byId: todoItem.id)
    }

    private func editTodoLocally(_ todoItem: TodoItem) {
        for index in todoItems.indices where todoItems[index].id == todoItem.id {
            todoItems[index] = todoItem
        }
    }

    // MARK: - Updating

    private func updateTodo(byId id: String) {
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

    private func updateTodoOnServer(with updatedTodo: TodoItem) async throws {

        let taskID = UUID().uuidString
        await MainActor.run {
            addTaskID(taskID)
        }

        var retryCounter = 1
        var isRequestSuccessful = false

        var currentDelay = minDelay

        while currentDelay < maxDelay && isRequestSuccessful == false {
            print("DEBUG: Начата попытка запроса номер \(retryCounter) для задачи с id = \(taskID)")

            do {
                let (_, revision) = try await service.updateElement(byId: updatedTodo.id, with: updatedTodo, revision: currentRevision)
                await MainActor.run {
                    currentRevision = revision
                    isDirty = false
                    deleteTaskID(taskID)
                }
                isRequestSuccessful = true
                print("DEBUG: Задача с id = \(taskID) выполнена с попытки номер \(retryCounter)")
                return
            } catch {
                print("DEBUG: Не получилось выполнить задачу с id = \(taskID) с попытки \(retryCounter)")
                retryCounter += 1
            }

            print("DEBUG: Установлена задержка в \(currentDelay) секунды")
            await Task.sleep(UInt64(currentDelay * Double(NSEC_PER_SEC)))
            currentDelay = calculateNextDelay(currentDelay: currentDelay)
        }

        print("DEBUG: currentDelay не был выполнена даже с Retry")
        print("DEBUG: Пробуем получить данные от сервера")

        do {
            try await loadTodoItems()
            await MainActor.run {
                isDirty = false
            }
            print("DEBUG: Локальные данные обновлены данными с сервера")
        } catch {
            print("DEBUG: Не получилось обновить локальные данные данными с сервера")
            await MainActor.run {
                isDirty = true
            }
        }

        await MainActor.run {
            deleteTaskID(taskID)
        }
    }

    // MARK: - Synchronization

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

    private func deleteTodoLocally(byId id: String) {
        for index in todoItems.indices where todoItems[index].id == id {
            todoItems.remove(at: index)
            return
        }
    }

    private func deleteTodoOnServer(byId id: String) async throws {

        let taskID = UUID().uuidString
        await MainActor.run {
            addTaskID(taskID)
        }

        var retryCounter = 1
        var isRequestSuccessful = false

        var currentDelay = minDelay

        while currentDelay < maxDelay && isRequestSuccessful == false {
            print("DEBUG: Начата попытка запроса номер \(retryCounter) для задачи с id = \(taskID)")

            do {
                let (_, revision) = try await service.deleteElement(byId: id, revision: currentRevision)
                await MainActor.run {
                    currentRevision = revision
                    isDirty = false
                    deleteTaskID(taskID)
                }
                isRequestSuccessful = true
                print("DEBUG: Задача с id = \(taskID) выполнена с попытки номер \(retryCounter)")
                return
            } catch {
                print("DEBUG: Не получилось выполнить задачу с id = \(taskID) с попытки \(retryCounter)")
                retryCounter += 1
            }

            print("DEBUG: Установлена задержка в \(currentDelay) секунды")
            await Task.sleep(UInt64(currentDelay * Double(NSEC_PER_SEC)))
            currentDelay = calculateNextDelay(currentDelay: currentDelay)
        }

        print("DEBUG: currentDelay не был выполнена даже с Retry")
        print("DEBUG: Пробуем получить данные от сервера")

        do {
            try await loadTodoItems()
            await MainActor.run {
                isDirty = false
            }
            print("DEBUG: Локальные данные обновлены данными с сервера")
        } catch {
            print("DEBUG: Не получилось обновить локальные данные данными с сервера")
            await MainActor.run {
                isDirty = true
            }
        }

        await MainActor.run {
            deleteTaskID(taskID)
        }
    }

    // MARK: - Loading

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

    // MARK: - Utilities

    private func noSameItem(withId id: String) -> Bool {
        for item in todoItems where item.id == id {
            return false
        }
        return true
    }

    private func getTodo(byId id: String) -> TodoItem? {
        for todoItem in todoItems where todoItem.id == id {
            return todoItem
        }
        return nil
    }
}

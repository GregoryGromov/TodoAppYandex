import Foundation
import Combine

class TaskListViewModel: ObservableObject {

    @Published var completedHidden = true
    @Published var sortingMode: SortMode = .byDate

    @Published var todoItems = [TodoItem]()
    @Published var selectedFilter: (TodoItem) -> Bool = { _ in true }

    @Published var showEditView = false
    @Published var showAddView = false

    @Published var selectedTaskId = ""
    @Published var selectedListDisplayMode: ListDisplayModificationOptions = .isDoneFilter
    
    @Published var isDirty = false // TODO: хранить в UserDefaults
    
    var isDoneCount: Int {
        todoItems.filter { $0.isDone }.count
    }

    private var cancellables = Set<AnyCancellable>()

    init() {
        FileCache.shared.$todoItems
            .sink { [weak self] todoItems in
                self?.todoItems = todoItems
            }
            .store(in: &cancellables)
        FileCache.shared.$isDirty
            .sink { [weak self] isDirty in
                self?.isDirty = isDirty
            }
            .store(in: &cancellables)
    }

//  MARK: - Loading data

    func loadTasks() async throws {
        try await FileCache.shared.loadTodoItems()
    }
    
//  MARK: - Data modification

    func switchIsDone(byId id: String) {
        FileCache.shared.switchIsDone(byId: id)
    }
    
//  MARK: - Filter
    
    func applyAllItemsFilter() {
        selectedFilter = { _ in true }
    }

    func applyIsDoneFilter() {
        selectedFilter = isDoneFilter
    }
    
    let isDoneFilter: (TodoItem) -> Bool = { todoItem in
        return !todoItem.isDone
    }
    
//  MARK: - Sorting
    
    func switchSorting() {
        switch sortingMode {
        case .byDate:
            sortByImportance()
            sortingMode = .byImportance
        case .byImportance:
            sortByDate()
            sortingMode = .byDate
        }
    }

    private func sortByDate() {
        if sortingMode != .byDate {
            todoItems.sort {$0.dateCreation > $1.dateCreation }
        }
    }

    private func sortByImportance() {
        if sortingMode != .byImportance {
            todoItems = sortArrayByImportance(todoItems)
        }
    }

    private func sortArrayByImportance(_ array: [TodoItem]) -> [TodoItem] {
        let sortedArray = array.sorted { (item1, item2) in
            if item1.importance == .important && item2.importance != .important {
                return true
            } else if item1.importance == .basic && item2.importance != .important && item2.importance != .basic {
                return true
            } else {
                return false
            }
        }

        return sortedArray
    }
    
//  MARK: - Show switching

    func showImportanceSortingButton() {
        selectedListDisplayMode = .importanceSorting
    }

    func showIsDoneFilterButton() {
        selectedListDisplayMode = .isDoneFilter
    }
    
    func switchShowCompleted() {
        completedHidden.toggle()
        if completedHidden {
            applyAllItemsFilter()
        } else {
            applyIsDoneFilter()
        }
    }
    
    func openEditPage(forItem item: TodoItem) {
        selectedTaskId = item.id
        showEditView = true
    }
    
//  MARK: - Utilities
    
    func getSelectedTodoItem() -> TodoItem? {
        for index in todoItems.indices where todoItems[index].id == selectedTaskId {
            return todoItems[index]
        }
        return nil
    }
}

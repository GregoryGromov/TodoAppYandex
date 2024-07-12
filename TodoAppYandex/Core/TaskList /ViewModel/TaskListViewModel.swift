//
//  TaskListViewModel.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 26.06.2024.
//

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

    private var cancellables = Set<AnyCancellable>()

    init() {
        FileCache.shared.$todoItems
            .sink { [weak self] todoItems in
                self?.todoItems = todoItems
            }
            .store(in: &cancellables)
    }

    var isDoneCount: Int {
        todoItems.filter { $0.isDone }.count
    }

    let isDoneFilter: (TodoItem) -> Bool = { todoItem in
        return !todoItem.isDone
    }

    func openEditPage(forItem item: TodoItem) {
        selectedTaskId = item.id
        showEditView = true
    }

    func applyAllItemsFilter() {
        selectedFilter = { _ in true }
    }

    func applyIsDoneFilter() {
        selectedFilter = isDoneFilter
    }

    func switchShowCompleted() {
        completedHidden.toggle()
        if completedHidden {
            applyAllItemsFilter()
        } else {
            applyIsDoneFilter()
        }
    }

    func switchIsDone(byId id: String) {
        FileCache.shared.switchIsDone(byId: id)
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

//  TODO: проверить, всегда ли работает правильно
    func sortArrayByImportance(_ array: [TodoItem]) -> [TodoItem] {
        let sortedArray = array.sorted { (item1, item2) in
            if item1.importance == .important && item2.importance != .important {
                return true
            } else if item1.importance == .ordinary && item2.importance != .important && item2.importance != .ordinary {
                return true
            } else {
                return false
            }
        }

        return sortedArray
    }

    func getSelectedTodoItem() -> TodoItem? {
        for index in todoItems.indices {
            if todoItems[index].id == selectedTaskId {
                return todoItems[index]
            }
        }

        return nil
    }

    func deleteItem(byId id: String) {
        FileCache.shared.deleteTodoItem(byId: id)
    }

    func showImportanceSortingButton() {
        selectedListDisplayMode = .importanceSorting
    }

    func showIsDoneFilterButton() {
        selectedListDisplayMode = .isDoneFilter
    }
}

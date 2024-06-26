//
//  TaskListViewModel.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 26.06.2024.
//

import Foundation

class TaskListViewModel: ObservableObject {
    
    var allTodoItems = TodoItem.MOCK
    
    @Published var completedHidden = true
    @Published var todoItems = TodoItem.MOCK
    @Published var selectedFilter: (TodoItem) -> Bool = { _ in true }
    
    var isDoneCount: Int {
        todoItems.filter{ $0.isDone }.count
    }
    
    let isDoneFilter: (TodoItem) -> Bool = { todoItem in
        return !todoItem.isDone
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
        for index in todoItems.indices {
            if todoItems[index].id == id {
                todoItems[index].isDone.toggle()
            }
        }
    }
    
    
    
}

//
//  TestViewModel.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 25.06.2024.
//

import Foundation

class TestViewModel: ObservableObject {
    
    @Published var name = ""
    
    let manager = FileCache(todoItems: [])
    
    func saveTodoItem() {
        let newTodoItem = TodoItem(
            text: name,
            importance: .ordinary,
            isDone: false,
            dateCreation: Date()
        )
        
        manager.addTodoItem(newTodoItem)
        try? manager.saveTodoItemsToFile()
    }
}

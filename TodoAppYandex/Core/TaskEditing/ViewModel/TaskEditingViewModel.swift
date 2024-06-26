//
//  TaskEditingViewModel.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 24.06.2024.
//
import SwiftUI
import Foundation

class TaskEditingViewModel: ObservableObject {
    
    init(mode: TodoEditMode, todoItem: TodoItem?) { // ВОПРОС: нужно ли оставлять свойство mode? Ведь по сути, если мы передаем какой-то item, то это уже говорит о том, что инициализацих происходит с цель редактирования имеющейся задачи.
//        С другой стороны, наличие данного свойства упрощает понимание кода и делает объект более масштабируемым
//        Как делать считается более правильным?
        
        self.showCalendar = false
        
        if mode == .create {
            if let todoItem = todoItem {
                
                self.text = todoItem.text
                self.selectedImportance = todoItem.importance
                
                if let deadline = todoItem.deadline {
                    self.deadlineSet = true
                    self.deadline = deadline
                } else {
                    self.deadlineSet = false
                    self.deadline = Date().addingTimeInterval(86_400) // 60 * 60 * 24 = 86400
                }
                
                return
                

                
                
            } else {
//                без добавленя этого не работает (хотя ниже, вне ифа мы все же инициализривем данные поля)
                self.text = ""
                self.selectedImportance = .ordinary
                self.deadlineSet = false
                self.deadline = Date().addingTimeInterval(86_400) // 60 * 60 * 24 = 86400
                
                return
            }
     
        }
        
        self.text = ""
        self.selectedImportance = .ordinary
        self.deadlineSet = false
        self.deadline = Date().addingTimeInterval(86_400) // 60 * 60 * 24 = 86400
        
        
        
        
    }
    
    @Published var text: String
    @Published var selectedImportance: Importance
    
    @Published var deadlineSet: Bool {
        didSet {
            if !deadlineSet {
                showCalendar = false
            }
        }
    }
    @Published var showCalendar = false
    @Published var deadline: Date

    
    
    func getPickerPreview(for importance: Importance) -> some View {
        switch importance {
        case .unimportant:
            return Image(systemName: "arrow.down").eraseToAnyView()
        case .ordinary:
            return Text("нет").eraseToAnyView()
        case .important:
            return Image(systemName: "exclamationmark.2").eraseToAnyView()
        }
    }
    
    
    
    
    
    
}



extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

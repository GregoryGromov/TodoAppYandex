//
//  TaskEditingViewModel.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 24.06.2024.
//
import SwiftUI
import Foundation

class TaskEditingViewModel: ObservableObject {
    
    
    
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
    
    @Published var color: Color
    
    @Published var dateCreation: Date?
    @Published var id: String?
    @Published var mode: TodoEditMode
    
    
    
    init(mode: TodoEditMode, todoItem: TodoItem?) {
        
        self.showCalendar = false
        self.mode = mode
        
        
        if mode == .edit {
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
                
                if let colorString = todoItem.color {
                    self.color = Color(hex: colorString)
                } else {
                    self.color = .white
                }
                
                
                
                
                self.dateCreation = todoItem.dateCreation
                self.id = todoItem.id
                
                
                
                return
                

                
                
            } else {
//                без добавленя этого не работает (хотя ниже, вне ифа мы все же инициализривем данные поля)
                self.text = ""
                self.selectedImportance = .ordinary
                self.deadlineSet = false
                self.deadline = Date().addingTimeInterval(86_400) // 60 * 60 * 24 = 86400
                
                self.color = .white
                
                
                
                
                return
            }
        }
        
        self.text = ""
        self.selectedImportance = .ordinary
        self.deadlineSet = false
        self.deadline = Date().addingTimeInterval(86_400) // 60 * 60 * 24 = 86400
        
        self.color = .white
        
        
        
        
        
        
        
    }
    
    
    
    
    
    

    
    
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

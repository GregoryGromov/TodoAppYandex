//
//  DetailViewIPad.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 29.06.2024.
//

import SwiftUI




struct DetailViewIPad: View {
    
    @Binding var todoItems: [TodoItem]
    @State var selectedTodoItem: TodoItem
    
    @State var showEditView = false
    
    
    var body: some View {
        List {
            Section {
//                Дизайн потом будет улучшен)) Пока сделал чисто макет, чтобы успеть до дедлайна)
                VStack {
                    Text(selectedTodoItem.text)
                    getPickerPreview(for: selectedTodoItem.importance)
                }
            }
            
            Section {
                if let deadline = selectedTodoItem.deadline {
                    Text(deadline.dayMonthYear)
                }
            }
            
            Section {
                HStack {
                    Button {
                        deleteItem()
                    } label: {
                        Text("Удалить")
                    }
                }
                
                HStack {
                    Button {
                        showEditView = true
                    } label: {
                        Text("Редактировать")
                    }
                }
            }
        }
        
        
        
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
    
    func deleteItem() {
        for index in todoItems.indices {
            if todoItems[index].id == selectedTodoItem.id {
                todoItems.remove(at: index)
                return
            }
        }
    }
}





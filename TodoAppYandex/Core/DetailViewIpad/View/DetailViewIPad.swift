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
            return ImageCollection.arrowDown.eraseToAnyView()
        case .ordinary:
            return Text("нет").eraseToAnyView()
        case .important:
            return ImageCollection.exclamationMark.eraseToAnyView()
        }
    }

    func deleteItem() {
        for index in todoItems.indices where todoItems[index].id == selectedTodoItem.id {
            todoItems.remove(at: index)
            return
        }
    }
}

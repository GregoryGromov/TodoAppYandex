//
//  TaskEditingView.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 24.06.2024.
//

import SwiftUI



extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter({$0.isKeyWindow})
            .first?
            .endEditing(force)
    }
}


struct TaskEditingView: View {
    
    @Environment(\.dismiss) var dismiss
//    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Environment(\.horizontalSizeClass)
        var horizontalSizeClass
        @Environment(\.verticalSizeClass)
        var verticalSizeClass
    
    
    @Binding var todoItems: [TodoItem]
    @StateObject var viewModel: TaskEditingViewModel
    
    @State var textEditorIsActive = false
    
    @State var color: Color?
    
    @State var showColorPicker = false
    

    init(mode: TodoEditMode, todoItem: TodoItem? = nil, todoItems: Binding<[TodoItem]>) {
        
        if mode == .create {
            self._viewModel = StateObject(
                wrappedValue: TaskEditingViewModel(mode: .create, todoItem: nil)
            )
        } else {
            if let todoItem = todoItem {
                self._viewModel = StateObject(
                    wrappedValue: TaskEditingViewModel(mode: .edit, todoItem: todoItem)
                )
            } else { // при правильном использовании, мы тут никогда не окажется. Можно ли как-то избежать написание кода ниже?
                self._viewModel = StateObject(
                    wrappedValue: TaskEditingViewModel(mode: .create, todoItem: nil)
                )
            }
        }
        
        self._todoItems = todoItems
        
        if let colorString = todoItem?.color {
            self.color = Color(hex: colorString)
        }
        
        
    }
    
    @State var keyBoardIsActive = false
 

    var body: some View {
            NavigationView {
                List {
                    
                    if UIDevice.current.orientation.isPortrait {
                    
                    
//                    if (horizontalSizeClass == .compact && verticalSizeClass == .regular) || (horizontalSizeClass == verticalSizeClass) {
                        
                        
                        
                        
                        
                        textEditorSection
                        importanceAndDateSection
                        colorSelectionSection
                        deleteButtonSection
                    } else {
                        if !textEditorIsActive {
                            HStack {
                                textEditorSection
                                    .onTapGesture {
                                        textEditorIsActive = true
                                        
                                    }
                                VStack {
                                    colorSelectionSection
                                    importanceAndDateSection
                                    deleteButtonSection
                                }
                            }
                        } else {
                            textEditorSection
                        }
                        
                        
                    }
                   
                }
                
  
                .listSectionSpacing(.compact)
                .navigationTitle("Дело")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("Отменить")
                                .foregroundStyle(.blue)
                        }
                        
                    }
                    
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        
                        Button {
                            if viewModel.mode == .create {
                                addTodoItem()
                            } else if viewModel.mode == .edit{
                                editTodoItem()
                            }
                            
                            dismiss()
                            
                        } label: {
                            Text("Сохранить")
                                .foregroundStyle(.blue)
                                .fontWeight(.semibold)
                                .disabled(viewModel.text.isEmpty)
                        }   
                    }
                }
            }
         
        

        
    }
    
    
    var textEditorSection: some View {
        Section {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.text)
                    .frame(minHeight: 100)
                    .padding()
                    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                        textEditorIsActive = true
                        }
//                    .simultaneousGesture(TapGesture().onEnded {
//                                    UIApplication.shared.windows.forEach { $0.endEditing(true) }
//                                })
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    
            }
        }
        
    }
    
    var importanceAndDateSection: some View {
        Section {
            HStack {
                Text("Важность")
                Spacer()

                Picker("", selection: $viewModel.selectedImportance) {
                    ForEach(Importance.allCases, id: \.self) { option in
                        viewModel.getPickerPreview(for: option)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Сделать до")
                    if viewModel.deadlineSet {
                        Text(viewModel.deadline.dayMonthYear)
                            .foregroundStyle(.blue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .onTapGesture {
                                viewModel.showCalendar.toggle()
                            }
                    }
                    
                }
                
                Spacer()
                Toggle("", isOn: $viewModel.deadlineSet)
            }
            
            if viewModel.showCalendar {
                HStack {
                    DatePicker(
                        "Enter your birthday",
                        selection: $viewModel.deadline,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .frame(maxHeight: 400)
                        
                    
                }
            }
        }
    }
    
    var deleteButtonSection: some View {
        Section {
            Button {
                dismiss()
                deleteTodoItem()
                
            } label: {
                HStack() {
                    Spacer()
                    Text("Удалить")
                    Spacer()
                }
            }
            .disabled(viewModel.text.isEmpty)
        }
    }
    
    var colorSelectionSection: some View {
        Section {
            HStack {
                Text(viewModel.color.toHex())
                    .fontWeight(.bold)
                    .padding(5)
                    .padding(.horizontal, 4)
                    .background(RoundedRectangle(cornerRadius: 15).fill(.gray).opacity(0.3))
                    .padding(.horizontal)
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(hex: viewModel.color.toHex()))
                    .frame(width: 50, height: 5)
                
                Spacer()
                
                Button {
                    showColorPicker = true
                } label: {
                    Text("Show picker")
                }
                
                
               
            }
        }     
        .sheet(isPresented: $showColorPicker) {
            CustomColorPicker(bgColor: $viewModel.color)
        }
    }
    
    
//    В будущем перенсти во viewModel
    func addTodoItem() {
        
        
        let color = viewModel.color
        
        var deadline: Date? = viewModel.deadline
        
        if !viewModel.deadlineSet {
            deadline = nil
        }
        
        let todoItem = TodoItem(
            text: viewModel.text,
            importance: viewModel.selectedImportance,
            deadline: deadline,
            isDone: false,
            dateCreation: Date(),
            color: color.toHex()
        )
        todoItems.append(todoItem)
        
        print("Добавленный hex", color.toHex())
        
    }
    
//    В будущем перенсти во viewModel
    func editTodoItem() {
        
        let color = viewModel.color
        
        if let id = viewModel.id {
            for index in todoItems.indices {
                if todoItems[index].id == id {
                    todoItems.remove(at: index)
                    
                    var deadline: Date? = viewModel.deadline
                    
                    if !viewModel.deadlineSet {
                        deadline = nil
                    }
                    
                    let todoItem = TodoItem(
                        text: viewModel.text,
                        importance: viewModel.selectedImportance,
                        deadline: deadline,
                        isDone: false,
                        dateCreation: viewModel.dateCreation ?? Date(),
                        color: color.toHex()
                    )
                    todoItems.append(todoItem)
                    
                    print("заменили")
                    
                    return
                    
                }
            }
        }
    
    }
    
    func deleteTodoItem() {
        if let id = viewModel.id {
            print("todoItems0.count", todoItems.count)
            for index in todoItems.indices {
                print("index", index)
                print("todoItems.count", todoItems.count)
                if todoItems[index].id == id {
                    todoItems.remove(at: index)
                    print("удалили")
                }
                return
            }
        }
    }
    
    
}





//
//  TaskListView.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 25.06.2024.
//

import SwiftUI

struct TaskListView: View {
    
    @State var selectedListDisplayMode: ListDisplayModificationOptions = .isDoneFilter
    
    @StateObject var viewModel = TaskListViewModel()
    
    
    
    

    var body: some View {
        NavigationView {
            
            VStack {
                List {
                    Section(header: topBar) {
                        ForEach(viewModel.todoItems.filter(viewModel.selectedFilter)) { item in
                            HStack {
                                HStack {
                                    if item.isDone {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    } else if item.importance == .important {
                                        ZStack {
                                            Image(systemName: "circle")
                                                .foregroundStyle(.red)
                                            Image(systemName: "circle.fill")
                                                .foregroundStyle(.red)
                                                .opacity(0.1)
                                            
                                        }
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundStyle(Color(.systemGray))
                                    }
                                }
                                .font(.title2)
                                .onTapGesture {
                                    viewModel.switchIsDone(byId: item.id)
                                }
                                
                                VStack(alignment: .leading) {
                                    HStack(spacing: 2) {
                                        if item.importance == .important && !item.isDone {
                                            Image(systemName: "exclamationmark.2")
                                                .foregroundStyle(.red)
                                                .fontWeight(.bold)
                                        }
                                        Text(item.text)
                                            .strikethrough(item.isDone ? true : false)
                                            .opacity(item.isDone ? 0.4 : 1)
                                        
//                                        Text(item.color ?? "no color now")
                                        
                                        
                                        
                                        if let colorString = item.color {
                                            RoundedRectangle(cornerRadius: 5)
                                                .foregroundStyle(Color(hex: colorString))
//
                                                .frame(width: 50, height: 5)
                                        }
                                        
                                        
                                    }
                                    
                                    if !item.isDone {
                                        if let deadline = item.deadline {
                                            HStack(spacing: 2) {
                                                Image(systemName: "calendar")
                                                Text(deadline.dayMonth)
                                                Spacer()
                                            }
                                            .opacity(0.4)
                                            .font(.caption)
                                        }
                                    }
                                    
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color(.systemGray3))
                            }
                            .padding(.vertical, 6)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    viewModel.deleteItem(byId: item.id)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .tint(.red)
                                
                                Button {
                                    viewModel.selectedTaskId = item.id
                                    viewModel.showEditView = true
                                } label: {
                                   Image(systemName: "info.circle")
                                }
                                .tint(Color(.systemGray).opacity(0.3))
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    viewModel.switchIsDone(byId: item.id)
                                } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                                .tint(.green)
                            }
                        }
                    }
                    
                    
                }
                .sheet(isPresented: $viewModel.showEditView) {
//                    Временный костыль
                    if let selectedItem = viewModel.getSelectedTodoItem() {
                        TaskEditingView(
                            mode: .edit,
                            todoItem: selectedItem,
                            todoItems: $viewModel.todoItems
                        )
                    } else {
                        Text("Успешно изменено")
                    }

                }
                
                
                .navigationTitle("Мои дела")
                .navigationBarTitleDisplayMode(.large)
                
            }
            .overlay {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
//                        ZStack {
                        Button {
                            viewModel.showAddView = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                        }
                        
                         
//                        }
                        Spacer()
                    }
                    .padding(.bottom, 25)
                }
            }
            
        }
        .sheet(isPresented: $viewModel.showAddView) {
            TaskEditingView(mode: .create, todoItems: $viewModel.todoItems) // ИСПРАВИТЬ
        }
        
        
    }
    
    var topBar: some View {
        HStack {
            Text("Выполнено — \(viewModel.isDoneCount)")
                .foregroundStyle(.gray)
            
            Spacer()
            

            
            Menu {
                Button("Сортировка по добавлению/важности", action: showImportanceSortingButton)
                Button("Скрыть/показать выполненное", action: showIsDoneFilterButton)
            } label: {
                Label("", systemImage: "line.horizontal.3.decrease")
            }
            
            switch selectedListDisplayMode {
            case .importanceSorting:
                Button {
                    viewModel.switchSorting()
                } label: {
                    if viewModel.sortingMode == .byDate {
                        Text("По важности")
                            .fontWeight(.semibold)
                    } else {
                        Text("По дате добавления")
                            .fontWeight(.semibold)
                    }
                }
            case .isDoneFilter:
                Button {
                    viewModel.switchShowCompleted()
                } label: {
                    if viewModel.completedHidden {
                        Text("Скрыть")
                            .fontWeight(.semibold)
                    } else {
                        Text("Показать")
                            .fontWeight(.semibold)
                    }
                }
            }
            
            
                    }
        .padding(.horizontal)
    }
    
    func showImportanceSortingButton() {
        selectedListDisplayMode = .importanceSorting
    }
    
    func showIsDoneFilterButton() {
        selectedListDisplayMode = .isDoneFilter
    }
     
}



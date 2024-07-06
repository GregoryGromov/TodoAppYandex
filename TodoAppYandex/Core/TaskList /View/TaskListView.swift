//
//  TaskListView.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 25.06.2024.
//

import SwiftUI

struct TaskListView: View {
    
    @StateObject var viewModel = TaskListViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: topBar) {
                        ForEach(viewModel.todoItems.filter(viewModel.selectedFilter)) { item in
                            HStack {
                                TodoCheckmarkLabel(item: item)
                                .onTapGesture {
                                    viewModel.switchIsDone(byId: item.id)
                                }
                                TodoInfoLabel(item: item)
                            }
                            .padding(.vertical, 6)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    viewModel.openEditPage(forItem: item)
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
                    // TODO: сделать это более изящно
                    if let selectedItem = viewModel.getSelectedTodoItem() {
                        TaskEditingView(
                            mode: .edit,
                            todoItem: selectedItem,
                            todoItems: $viewModel.todoItems
                        )
                    } else {
                        Text("Ошибка: невозможно открыть страницу редактирования задчи")
                    }
                    
                }
                .navigationTitle("Мои дела")
                .navigationBarTitleDisplayMode(.large)
                
            }
            .overlay {
                plusButton
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        
                        
                        
                        SwiftUICalendar()
                    } label: {
                        Image(systemName: "calendar")
                            .font(.title3)
                    }
                    
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
                Button("Сортировка по добавлению/важности", action: viewModel.showImportanceSortingButton)
                Button("Скрыть/показать выполненное", action: viewModel.showIsDoneFilterButton)
            } label: {
                Label("", systemImage: "line.horizontal.3.decrease")
            }
            
            switch viewModel.selectedListDisplayMode {
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
    
    var plusButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    viewModel.showAddView = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                }
                
                Spacer()
            }
            .padding(.bottom, 25)
        }
    }    
}



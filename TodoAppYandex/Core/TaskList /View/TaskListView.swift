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
                                    .onTapGesture {
                                        viewModel.openEditPage(forItem: item)
                                    }
                            }
                            .padding(.vertical, 6)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    viewModel.deleteTodoItem(byId: item.id)
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                        .tint(.red)
                                }
                                Button {
                                    viewModel.openEditPage(forItem: item)
                                } label: {
                                    ImageCollection.info
                                }
//                                .tint(Color(.systemGray).opacity(0.3))

                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    viewModel.switchIsDone(byId: item.id)
                                } label: {
                                    ImageCollection.checkmarkCircle
                                }
                                .tint(.green)
                            }
                        }

                        newTodoCell
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

            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SwiftUICalendar()
                    } label: {
                        ImageCollection.calendar
                            .font(.title3)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !viewModel.isTaskIDsEmpty {
                        ProgressView()
                    } else if viewModel.isDirty {
                        ImageCollection.cloudError
                            .font(.title3)
                            .foregroundStyle(.red)
                    } else {
                        ImageCollection.cloud
                            .font(.title3)
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddView) {
            TaskEditingView(mode: .create, todoItems: $viewModel.todoItems) // ИСПРАВИТЬ
        }
        .onAppear {
            Task {
                do {
                    try await viewModel.loadTasks()
                } catch {
                    print(error)
                }
            }
        }
        .overlay {
            VStack {
                Spacer()
                addTodoButton
            }

        }

    }

    private var addTodoButton: some View {
        AddNewItemButton {
            viewModel.showAddView = true
        }
        .padding(20)
    }

    private var newTodoCell: some View {
        HStack {
            Text("Новое")
                .foregroundColor(.gray)
                .padding(.vertical, 8)
                .padding(.leading, 35)
            Spacer()
        }
        .onTapGesture {
            viewModel.showAddView = true
        }
    }

    private var topBar: some View {
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
                    ImageCollection.plusCircle
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

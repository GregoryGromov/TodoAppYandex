import SwiftUI

private enum LayoutConstants {
    static let todoListVerticalPadding: CGFloat = 6

    static let addTodoSectionTextVerticalPadding: CGFloat = 8
    static let addTodoSectionTextLeadingPadding: CGFloat = 35

    static let addTodoButtonBottomPadding: CGFloat = 45
}

struct TaskListView: View {

    let dataManager: FileCache
    @ObservedObject var viewModel: TaskListViewModel

    init() {
        let dataManager = FileCache()
        self.dataManager = dataManager
        self.viewModel = TaskListViewModel(dataManager: dataManager)
    }

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: topBar) {
                        todoList
                        newTodoCell
                    }
                }
                .scrollContentBackground(.hidden)
                .background(ColorCollection.background)
                .sheet(isPresented: $viewModel.showEditView) {
                    taskEditingView
                }
                .navigationTitle("Мои дела")
                .navigationBarTitleDisplayMode(.large)
            }

            .toolbar {
                calendarButton
                networkTaskStatus
            }
        }
        .sheet(isPresented: $viewModel.showAddView) {
            TaskEditingView(mode: .create, todoItems: $viewModel.todoItems, dataManager: dataManager) // TODO: ИСПРАВИТЬ архитектуру
        }
        .onAppear {
//            viewModel.loadTasks()
        }
        .overlay {
            VStack {
                Spacer()
                addTodoButton
            }
        }
    }

    private var todoList: some View {
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
            .padding(.vertical, LayoutConstants.todoListVerticalPadding)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button {
                    viewModel.deleteTodoItem(byId: item.id)
                } label: {
                    Label("Delete", systemImage: ImageCollection.trashName)
                        .tint(.red)
                }
                Button {
                    viewModel.openEditPage(forItem: item)
                } label: {
                    ImageCollection.info
                }
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
    }

    private var taskEditingView: some View {
        // TODO: сделать это более изящно
        if let selectedItem = viewModel.getSelectedTodoItem() {
            TaskEditingView(
                mode: .edit,
                todoItem: selectedItem,
                todoItems: $viewModel.todoItems,
                dataManager: dataManager
            ).eraseToAnyView()
        } else {
            Text("Ошибка: невозможно открыть страницу редактирования задчи").eraseToAnyView()
        }
    }

    private var calendarButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            NavigationLink {
                ZStack {
                    SwiftUICalendar()
                    RestorationSignView(dateString: "16:00 24.07.2024")
                }
            } label: {
                ImageCollection.calendar
                    .font(.title3)
            }
        }
    }

    private var networkTaskStatus: some ToolbarContent {
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

    private var addTodoButton: some View {
        AddNewItemButton {
            viewModel.showAddView = true
        }
    }

    private var newTodoCell: some View {
        HStack {
            Text("Новое")
                .foregroundColor(.gray)
                .padding(.vertical, LayoutConstants.addTodoSectionTextVerticalPadding)
                .padding(.leading, LayoutConstants.addTodoSectionTextLeadingPadding)
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

            switch viewModel.selectedListDisplayMode {
            case .importanceSorting:
                Button {
                    viewModel.switchSorting()
                } label: {
                    if viewModel.sortingMode == .byDate {
                        Text("По важности")
                            .fontWeight(.semibold)
                    } else {
                        Text("По дате")
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
            Menu {
                Button("Сортировка по добавлению/важности", action: viewModel.showImportanceSortingButton)
                Button("Скрыть/показать выполненное", action: viewModel.showIsDoneFilterButton)
            } label: {
                Label("", systemImage: ImageCollection.filterName)
            }
        }
        .textCase(nil)
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
            .padding(.bottom, LayoutConstants.addTodoButtonBottomPadding)
        }
    }
}

import SwiftUI
import CustomColorPicker

private enum LayoutConstants {
    static let textEditorMinHeight: CGFloat = 100

    static let importancePickerWidth: CGFloat = 180
    static let calendarMaxHeight: CGFloat = 400

    static let colorCodeBackgroundPadding: CGFloat = 7
    static let colorCodeBackgroundCornerRadius: CGFloat = 20
    static let colorCodeVerticalPadding: CGFloat = 4

    static let colorPickerButtonDiameter: CGFloat = 44
}

struct TaskEditingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass) var verticalSizeClass

    @StateObject var viewModel: TaskEditingViewModel

    init(mode: TodoEditMode, todoItem: TodoItem? = nil, todoItems: Binding<[TodoItem]>, dataManager: FileCache) {

        if mode == .create {
            self._viewModel = StateObject(
                wrappedValue: TaskEditingViewModel(mode: .create, todoItem: nil, dataManager: dataManager)
            )
        } else {
            if let todoItem = todoItem {
                self._viewModel = StateObject(
                    wrappedValue: TaskEditingViewModel(mode: .edit, todoItem: todoItem, dataManager: dataManager)
                )
            } else { // TODO: при правильном использовании, мы тут никогда не окажется. Переделать архитектуру
                self._viewModel = StateObject(
                    wrappedValue: TaskEditingViewModel(mode: .create, todoItem: nil, dataManager: dataManager)
                )
            }
        }
        if let colorString = todoItem?.color {
            viewModel.color = Color(hex: colorString)
        }
    }

    var body: some View {
        NavigationView {
            if verticalSizeClass == .regular {
                verticalOrientationView
            } else {
                horizontalOrientationView
            }
        }
    }

    private var verticalOrientationView: some View {
        List {
            textField
            importanceAndDateSection
            colorSelectionSection
            deleteButtonSection
        }
        .scrollContentBackground(.hidden)
        .background(ColorCollection.background)
        .listSectionSpacing(.compact)
        .navigationTitle("Дело")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            cancelToolBarItem
            saveToolBarItem
        }
    }

    private var horizontalOrientationView: some View {
        GeometryReader { proxy in
            VStack {
                HStack {
                    List {
                        textField
                            .frame(
                                minHeight: proxy.size.height - proxy.safeAreaInsets.bottom - proxy.safeAreaInsets.top
                            )
                    }
                    .scrollIndicators(.hidden)
                    List {
                        importanceAndDateSection
                        colorSelectionSection
                        deleteButtonSection
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .scrollContentBackground(.hidden)
            .background(ColorCollection.background)
            .toolbar {
                cancelToolBarItem
                saveToolBarItem
            }
        }
    }

    private var textField: some View {
        TextFieldCell(text: $viewModel.text, color: $viewModel.color)
    }

    private var textEditorSection: some View {
        Section {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.text)
                    .frame(minHeight: LayoutConstants.textEditorMinHeight)
                    .padding()
            }
        }
    }

    private var importanceAndDateSection: some View {
        Section {
            HStack {
                Text("Важность")
                Spacer()
                Picker("", selection: $viewModel.selectedImportance) {
                    ForEach(Importance.allCases, id: \.self) { option in
                        if option == .important {
                            ImageCollection.exclamationMark
                                .fontWeight(.bold)
                                .foregroundStyle(.red)
                        } else {
                            viewModel.getPickerPreview(for: option)
                        }
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: LayoutConstants.importancePickerWidth)
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
                        "Enter deadline",
                        selection: $viewModel.deadline,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .frame(maxHeight: LayoutConstants.calendarMaxHeight)
                }
            }
        }
    }

    private var deleteButtonSection: some View {
        Section {
            Button {
                viewModel.deleteTodo()
                dismiss()
            } label: {
                HStack {
                    Spacer()
                    Text("Удалить")
                        .foregroundStyle(.red)
                    Spacer()
                }
            }
            .disabled(viewModel.text.isEmpty)
        }
    }

    private var colorSelectionSection: some View {
        Section {
            HStack {
                Text(viewModel.color.toHex())
                    .fontWeight(.semibold)
                    .padding(LayoutConstants.colorCodeBackgroundPadding)
                    .background(
                        RoundedRectangle(cornerRadius: LayoutConstants.colorCodeBackgroundCornerRadius)
                            .fill(.lightGray)
                    )
                    .padding(.vertical, LayoutConstants.colorCodeVerticalPadding)

                Spacer()

                Button {
                    viewModel.showColorPicker = true
                    viewModel.colorIsSet = true // TODO: лучше проработать логику изменения данного свойства
                } label: {
                    ColorPickerOpenButton(color: viewModel.color, diameter: LayoutConstants.colorPickerButtonDiameter)
                }
            }
        }
        .sheet(isPresented: $viewModel.showColorPicker) {
            ZStack {
                CustomColorPicker.LocalColorPicker(selectedColor: $viewModel.color, backgroundColor: ColorCollection.background)
            }
        }
    }

    private var cancelToolBarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Text("Отменить")
                    .foregroundStyle(.blue)
            }
        }
    }

    private var saveToolBarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                if viewModel.mode == .create {
                    viewModel.addTodoItem()
                } else if viewModel.mode == .edit {
                    viewModel.editTodoItem()
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

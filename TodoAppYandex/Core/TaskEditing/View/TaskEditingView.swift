import SwiftUI
import CustomPicker

struct TaskEditingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: TaskEditingViewModel

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
            } else { // TODO: при правильном использовании, мы тут никогда не окажется. Можно ли как-то избежать написание кода ниже?
                self._viewModel = StateObject(
                    wrappedValue: TaskEditingViewModel(mode: .create, todoItem: nil)
                )
            }
        }
        if let colorString = todoItem?.color {
            self.viewModel.color = Color(hex: colorString)
        }
    }

    var body: some View {
        NavigationView {
            List {
                textEditorSection
                importanceAndDateSection
                colorSelectionSection
                deleteButtonSection
            }
            .listSectionSpacing(.compact)
            .navigationTitle("Дело")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                cancelToolBarItem
                saveToolBatItem
            }
        }
    }

    var textEditorSection: some View {
        Section {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.text)
                    .frame(minHeight: 100)
                    .padding()
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
            } label: {
                HStack {
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
                    viewModel.showColorPicker = true
                    viewModel.colorIsSet = true // TODO: лучше проработать логику изменения данного свойства
                } label: {
                    Text("Show picker")
                }
            }
        }
        .sheet(isPresented: $viewModel.showColorPicker) {
            CustomPicker.ColorPickerUI(bgColor: $viewModel.color)
        }
    }

    var cancelToolBarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Text("Отменить")
                    .foregroundStyle(.blue)
            }
        }
    }

    var saveToolBatItem: some ToolbarContent {
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

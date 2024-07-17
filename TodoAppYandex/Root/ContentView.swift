import SwiftUI

struct ContentView: View {

    let manager = DefaultNetworkingService()

    let testTodoItem = TodoItem(
        id: "pchelaID3",
        text: "Обновленная штука",
        importance: .important,
        deadline: nil,
        isDone: false,
        dateCreation: Date(),
        dateChanging: Date(),
        color: "#32892899"
    )

    var body: some View {
        TaskListView()
            .onAppear {
                Task {
//                    Обновить список
//                    try await manager.updateList(with: TestForDefaultNetworkingService().MOCK)

//                    Получить все элементы и вывести их
//                    let items = try await manager.getList()
//                    print("Ура, мы получили элементы с сервера:")
//                    for item in items {
//                        print(item)
//                    }
                    
                    
//                    Обновить элемент
//                    do {
//                        try await manager.updateElement(byId: "pchelaID3", with: testTodoItem, revision: 10)
//                    } catch {
//                        print(error)
//                    }
                    
                    
                    
                    

//                    Добавить элемент
//                    do {
//                        try await manager.addElement(testTodoItem, revision: 8)
//                    } catch {
//                        print(error)
//                    }

//                    Удалить элемент
//                    do {
//                        try await manager.deleteElement(byId: "osaID")
//                    } catch {
//                        print(error)
//                    }

//                    Получить элемент по id
//                    do {
//                        try await manager.getElement(byId: "osaID2")
//                    } catch {
//                        print(error)
//                    }

                }

            }
    }
}

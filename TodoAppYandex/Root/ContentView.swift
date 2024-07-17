import SwiftUI

struct ContentView: View {

    let manager = DefaultNetworkingService()

    let testTodoItem = TodoItem(
        id: "pchelaID4",
        text: "Обновленное Хо-хо",
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
//                    let items = try await manager.updateList(with: TestForDefaultNetworkingService().MOCK)
//                    print(items)

//                    Получить все элементы и вывести их
                    let items = try await manager.getList()
                    print("Ура, мы получили элементы с сервера:")
                    for item in items {
                        print(item)
                    }
                    
                    
//                    Обновить элемент
//                    do {
//                        let el = try await manager.updateElement(byId: "pchelaID4", with: testTodoItem, revision: 13)
//                        print(el)
//                    } catch {
//                        print(error)
//                    }
                    
                    
                    
                    

//                    Добавить элемент
//                    do {
//                        let el = try await manager.addElement(testTodoItem, revision: 12)
//                        print(el)
//                    } catch {
//                        print(error)
//                    }

//                    Удалить элемент
//                    do {
//                        let el = try await manager.deleteElement(byId: "pchelaID2", revision: 14)
//                        print(el)
//                    } catch {
//                        print(error)
//                    }

//                    Получить элемент по id
//                    do {
//                        let el = try await manager.getElement(byId: "pchelaID2")
//                        print(el)
//                    } catch {
//                        print(error)
//                    }

                }

            }
    }
}

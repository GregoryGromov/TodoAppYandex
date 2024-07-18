import SwiftUI

struct ContentView: View {

    let manager = DefaultNetworkingService()
    
    let items = TodoItem.MOCK2

    let testTodoItem = TodoItem(
        id: "pchelaID2",
        text: "Обновленное x100 Хо-хо",
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
//                    let items = try await manager.updateList(with: items, revision: 22)
//                    print(items)

//                    Получить все элементы и вывести их
//                    let (items, revision) = try await manager.getList()
//                    print("Ура, мы получили элементы с сервера:")
//                    print("Ревизия:", revision)
//                    for item in items {
//                        print(item)
//                    }
                    
                    
//                    Обновить элемент
//                    do {
//                        let el = try await manager.updateElement(byId: "pchelaID2", with: testTodoItem, revision: 18)
//                        print(el)
//                    } catch {
//                        print(error)
//                    }
                    
                    
                    
                    

//                    Добавить элемент
//                    do {
//                        let el = try await manager.addElement(testTodoItem, revision: 16)
//                        print(el)
//                    } catch {
//                        print(error)
//                    }

//                    Удалить элемент
//                    do {
//                        let el = try await manager.deleteElement(byId: "pchelaID3", revision: 21)
//                        print(el)
//                    } catch {
//                        print(error)
//                    }

//                    Получить элемент по id
//                    do {
//                        let el = try await manager.getElement(byId: "pchelaID3")
//                        print(el)
//                    } catch {
//                        print(error)
//                    }

                }

            }
    }
}

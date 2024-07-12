import Foundation

extension TodoItem {

    static var MOCK: [TodoItem] {
        return [
            TodoItem(
                text: "Помыть посуду",
                importance: .important,
                isDone: false,
                dateCreation: Date(timeIntervalSince1970: 4398247)
            ),
            TodoItem(
                text: "Помыть собаку",
                importance: .ordinary,
                isDone: true,
                dateCreation: Date(timeIntervalSince1970: 439824700)
            ),
            TodoItem(
                text: "Выкинуть дерево",
                importance: .unimportant,
                deadline: Date(),
                isDone: false,
                dateCreation: Date()
            ),
            TodoItem(
                text: "Вырастить мусор",
                importance: .important,
                isDone: false,
                dateCreation: Date(timeIntervalSince1970: 23982470)
            ),
            TodoItem(
                text: "Выкинуть дерево",
                importance: .unimportant,
                deadline: Date().addingTimeInterval(3243203023),
                isDone: false,
                dateCreation: Date()
            ),
            TodoItem(
                text: "Выкинуть дерево",
                importance: .unimportant,
                deadline: Date().addingTimeInterval(39243203023),
                isDone: false,
                dateCreation: Date()
            ),
            TodoItem(
                text: "Выкинуть дерево",
                importance: .unimportant,
                deadline: Date().addingTimeInterval(2243203023),
                isDone: false,
                dateCreation: Date()
            ),
            TodoItem(
                text: "Выкинуть дерево",
                importance: .unimportant,
                deadline: Date().addingTimeInterval(10243203023),
                isDone: false,
                dateCreation: Date()
            )
        ]
    }

    var json: Any {

        var dictionary = [
            "id": self.id,
            "text": self.text,
            "isDone": self.isDone,
            "dateCreation": self.dateCreation.convertToString()
        ] as [String: Any]

        if importance != .ordinary {
            dictionary["importance"] = importance.rawValue
        }

        if let deadline = self.deadline {
            dictionary["deadline"] = deadline.convertToString()
        }

        if let dateChanging = self.dateChanging {
            dictionary["dateChanging"] = dateChanging.convertToString()
        }

        return dictionary
    }

    static func parse(json: Any) -> TodoItem? {

        guard let jsonObject = json as? [String: Any] else {
            print("Error converting input json to type [String: Any]")
            return nil
        }

        // извлекаем из JSON обязательные поля
        guard let id = jsonObject["id"] as? String,
              let text = jsonObject["text"] as? String,
              let isDone = jsonObject["isDone"] as? Bool,
              let dateCreationAsString = jsonObject["dateCreation"] as? String

        else { return nil }

        let importanceString = jsonObject["importance"] as? String

        var importance = Importance.ordinary

        if let importanceFromJSON = importanceString?.convertToImportance() {
            importance = importanceFromJSON
        }

        // проверяем, удалось ли перевести dateCreation из типа String в тип Date
        guard
            let dateCreation = dateCreationAsString.convertToDate()

        else { return nil }

        // определяем необязательные поля и изначально инициализируем их nil
        var deadline: Date?
        var dateChanging: Date?

        // проверяем, задан ли дедлайн
        if let deadlineAsString = jsonObject["deadline"] as? String {
            if let deadlineFromJSON = deadlineAsString.convertToDate() {
                deadline = deadlineFromJSON
            }
        }

        // проверяем, задана ли дата изменения
        if let dateChangingAsString = jsonObject["dateChanging"] as? String {
            if let dateChangingFromJSON = dateChangingAsString.convertToDate() {
                dateChanging = dateChangingFromJSON
            }
        }

        // создаем экземпляр TodoItem с ранее полученными данными
        let todoItem = TodoItem(id: id, text: text, importance: importance, deadline: deadline, isDone: isDone, dateCreation: dateCreation, dateChanging: dateChanging)
        return todoItem

    }

    //    данная функция требует чтобы столбцы, находящиеся в файле типа CSV, шли в порядке, как в инициализаторе TodoItem
    //    то есть: id, text, importance, deadline, isDone, dateCreation, dateChanging
    //    (конечно, некоторые опциональные столбцы могут быть пропушены, однако если в некоторой строке будет пропущен неопциональный столбец, функция вернет nil)

    //    пример входных данный, которые может обрабатывать функция:
    // let CSVExample = """
    // 4ocnho43yrpq,write to Misha,,,false,2024-06-18 20:05:42,2023-06-18 11:06:29
    // fu39ubjhaq12,finish the program,,,true,2024-06-18 15:05:42,
    // """
    static func parseCSV(_ csvString: String) -> [TodoItem]? {

        let lines = csvString.split(separator: "\n").map { String($0) }

        var todoItems = [TodoItem]()

        for line in lines {
            let elements = line.components(separatedBy: ",")

            if elements.count == 7 {
                let id = elements[0]
                let text = elements[1]

                guard
                    let isDone = Bool(elements[4]),
                    let importance = elements[2].convertToImportance(),
                    let dateCreation = elements[5].convertToDate()
                else { return nil }

                let deadline = elements[3].convertToDate()
                let dateChanging = elements[6].convertToDate()

                let todoItem = TodoItem(id: id, text: text, importance: importance, deadline: deadline, isDone: isDone, dateCreation: dateCreation, dateChanging: dateChanging)

                todoItems.append(todoItem)
            } else {
                print("Неверный формат CSV файла: в некоторой строке меньше семи столбцов")
            }
        }

        return todoItems
    }

    static func convertToCSV(todoItems: [TodoItem]) -> String {

        if todoItems.isEmpty {
            return ""
        }

        var CSVResult = ""

        for todoItem in todoItems {

            //      используем этот необычный метод, чтобы получить доступ к полям структуры, не обращаясь к ним напрямую по именам
            let mirror = Mirror(reflecting: todoItem)

            var CSVLine = ""

            for (_, value) in mirror.children {

                if let unwrappedValue = value as? String {
                    CSVLine += "\(unwrappedValue),"
                } else if let unwrappedValue = value as? Bool {
                    CSVLine += "\(unwrappedValue),"
                } else if let unwrappedValue = value as? Date {
                    CSVLine += "\(unwrappedValue.convertToString()),"
                } else if let unwrappedValue = value as? Importance {
                    CSVLine += "\(unwrappedValue.rawValue),"
                } else {
                    CSVLine += ","
                }
            }

            CSVLine.removeLast() // убираем последнюю запятую из строки
            CSVLine.append("\n")

            CSVResult.append(CSVLine)
        }

        CSVResult.removeLast()

        return CSVResult
    }
}

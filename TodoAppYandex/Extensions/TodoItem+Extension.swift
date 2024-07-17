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
                importance: .basic,
                isDone: true,
                dateCreation: Date(timeIntervalSince1970: 439824700)
            ),
            TodoItem(
                text: "Выкинуть дерево",
                importance: .low,
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
                importance: .low,
                deadline: Date().addingTimeInterval(3243203023),
                isDone: false,
                dateCreation: Date()
            ),
            TodoItem(
                text: "Выкинуть дерево",
                importance: .low,
                deadline: Date().addingTimeInterval(39243203023),
                isDone: false,
                dateCreation: Date()
            ),
            TodoItem(
                text: "Выкинуть дерево",
                importance: .low,
                deadline: Date().addingTimeInterval(2243203023),
                isDone: false,
                dateCreation: Date()
            ),
            TodoItem(
                text: "Выкинуть дерево",
                importance: .low,
                deadline: Date().addingTimeInterval(10243203023),
                isDone: false,
                dateCreation: Date()
            )
        ]
    }

    var json: Any {

        var dictionary = [
            JSONKeys.id: self.id,
            JSONKeys.text: self.text,
            JSONKeys.isDone: self.isDone,
            JSONKeys.dateCreation: self.dateCreation.convertToString()
        ] as [String: Any]

        if importance != .basic {
            dictionary[JSONKeys.importance] = importance.rawValue
        }

        if let deadline = self.deadline {
            dictionary[JSONKeys.deadline] = deadline.convertToString()
        }

        if let dateChanging = self.dateChanging {
            dictionary[JSONKeys.dateChanging] = dateChanging.convertToString()
        }

        if let color = self.color {
            dictionary[JSONKeys.color] = color
        }

        return dictionary
    }

    var jsonNetworking: Any {

        var dictionary = [
            JSONKeys.id: self.id,
            JSONKeys.text: self.text,
            JSONKeys.isDone: self.isDone,
            JSONKeys.dateCreation: self.dateCreation.convertToUnixTimestamp()
        ] as [String: Any]

        if importance != .basic {
            dictionary[JSONKeys.importance] = importance.rawValue
        }

        if let deadline = self.deadline {
            dictionary[JSONKeys.deadline] = deadline.convertToUnixTimestamp()
        }

        if let dateChanging = self.dateChanging {
            dictionary[JSONKeys.dateChanging] = dateChanging.convertToUnixTimestamp()
        }

        if let color = self.color {
            dictionary[JSONKeys.color] = color
        }

        return dictionary
    }

    static func parse(json: Any) throws -> TodoItem? {

        guard let jsonObject = json as? [String: Any] else {
            throw DataStorageError.convertingDataFailed
        }

        guard let id = jsonObject[JSONKeys.id] as? String,
              let text = jsonObject[JSONKeys.id] as? String,
              let isDone = jsonObject[JSONKeys.isDone] as? Bool,
              let dateCreationAsString = jsonObject[JSONKeys.dateChanging] as? String

        else { return nil }

        let importanceString = jsonObject[JSONKeys.importance] as? String

        var importance = Importance.basic

        if let importanceFromJSON = importanceString?.convertToImportance() {
            importance = importanceFromJSON
        }

        guard
            let dateCreation = dateCreationAsString.convertToDate()

        else { return nil }

        var deadline: Date?
        var dateChanging: Date?

        if let deadlineAsString = jsonObject[JSONKeys.deadline] as? String {
            if let deadlineFromJSON = deadlineAsString.convertToDate() {
                deadline = deadlineFromJSON
            }
        }

        if let dateChangingAsString = jsonObject[JSONKeys.dateChanging] as? String {
            if let dateChangingFromJSON = dateChangingAsString.convertToDate() {
                dateChanging = dateChangingFromJSON
            }
        }

        let todoItem = TodoItem(id: id, text: text, importance: importance, deadline: deadline, isDone: isDone, dateCreation: dateCreation, dateChanging: dateChanging)
        return todoItem
    }

    static func parseNetworking(json: Any) throws -> TodoItem? {
        guard let jsonObject = json as? [String: Any] else {
            throw DataStorageError.convertingDataFailed
        }
        guard let id = jsonObject[JSONKeys.id] as? String,
              let text = jsonObject[JSONKeys.id] as? String,
              let isDone = jsonObject[JSONKeys.isDone] as? Bool,
              let dateCreationAsInt = jsonObject[JSONKeys.dateChanging] as? Int
        else { return nil }

        var importance = Importance.basic
        let importanceString = jsonObject[JSONKeys.importance] as? String
        if let importanceFromJSON = importanceString?.convertToImportance() {
            importance = importanceFromJSON
        }

        let dateCreation = dateCreationAsInt.toDate()

        var deadline: Date?
        var dateChanging: Date?

        if let deadlineAsInt = jsonObject[JSONKeys.deadline] as? Int {
            deadline = deadlineAsInt.toDate()
        }

        if let dateChangingAsInt = jsonObject[JSONKeys.dateChanging] as? Int {
            dateChanging = dateChangingAsInt.toDate()
        }

        let color = jsonObject[JSONKeys.color] as? String ?? nil

        let todoItem = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            dateCreation: dateCreation,
            dateChanging: dateChanging,
            color: color
        )
        return todoItem
    }

    static func parseCSV(_ csvString: String) throws -> [TodoItem]? {

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

                let todoItem = TodoItem(
                    id: id,
                    text: text,
                    importance: importance,
                    deadline: deadline,
                    isDone: isDone,
                    dateCreation: dateCreation,
                    dateChanging: dateChanging
                )

                todoItems.append(todoItem)
            } else {
                throw DataStorageError.invalidCSVFormat
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

            CSVLine.removeLast()
            CSVLine.append("\n")

            CSVResult.append(CSVLine)
        }

        CSVResult.removeLast()

        return CSVResult
    }
}

import XCTest
@testable import TodoAppYandex

final class ParsingFromJSONTests: XCTestCase {

    func testJSONParsingWithAllNotNilProperties() {
        let todoItemJSON = [
            "id": "testId3",
            "text": "Почистить песчаную дорогу от песка",
            "importance": "unimportant",
            "deadline": "1970-01-01 03:20:34",
            "isDone": false,
            "dateCreation": "1970-01-01 03:20:30",
            "dateChanging": "1970-01-01 03:20:31"
        ] as [String: Any]

        let todoItem = TodoItem.parse(json: todoItemJSON)!

        XCTAssertEqual(todoItem.id, "testId3")
        XCTAssertEqual(todoItem.text, "Почистить песчаную дорогу от песка")
        XCTAssertEqual(todoItem.importance, Importance.unimportant)
        XCTAssertEqual(todoItem.deadline, Date(timeIntervalSince1970: 1234))
        XCTAssertEqual(todoItem.isDone, false)
        XCTAssertEqual(todoItem.dateCreation, Date(timeIntervalSince1970: 1230))
        XCTAssertEqual(todoItem.dateChanging, Date(timeIntervalSince1970: 1231))
    }

    func testParsingWithOnlyRequiredValues() {
        let todoItemJSON = [
            "id": "testId3",
            "text": "Покрасить траву в зеленый цвет",
            "importance": "unimportant",
            "isDone": false,
            "dateCreation": "1970-01-01 03:20:30"
        ] as [String: Any]

        let todoItem = TodoItem.parse(json: todoItemJSON)!

        XCTAssertEqual(todoItem.id, "testId3")
        XCTAssertEqual(todoItem.text, "Покрасить траву в зеленый цвет")
        XCTAssertEqual(todoItem.importance, Importance.unimportant)
        XCTAssertEqual(todoItem.isDone, false)
        XCTAssertEqual(todoItem.dateCreation, Date(timeIntervalSince1970: 1230))

        XCTAssertNil(todoItem.deadline)
        XCTAssertNil(todoItem.dateChanging)
    }

//    Тест парсинга словоря без указанной важности
    func testParsingWithoutImportacne() {

        let todoItemJSON = [
            "id": "testId3",
            "text": "Почистить песчаную дорогу от песка",
            "deadline": "1970-01-01 03:20:34",
            "isDone": false,
            "dateCreation": "1970-01-01 03:20:30",
            "dateChanging": "1970-01-01 03:20:31"

        ] as [String: Any]

        let todoItem = TodoItem.parse(json: todoItemJSON)!

        XCTAssertEqual(todoItem.id, "testId3")
        XCTAssertEqual(todoItem.text, "Почистить песчаную дорогу от песка")

        XCTAssertEqual(todoItem.importance, Importance.ordinary)

        XCTAssertEqual(todoItem.deadline, Date(timeIntervalSince1970: 1234))
        XCTAssertEqual(todoItem.isDone, false)
        XCTAssertEqual(todoItem.dateCreation, Date(timeIntervalSince1970: 1230))
        XCTAssertEqual(todoItem.dateChanging, Date(timeIntervalSince1970: 1231))
    }

}

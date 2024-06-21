import XCTest
@testable import TodoAppYandex

final class ConvertToJSONTests: XCTestCase {
    
    //    Тестируем var json: Any - самый обычный вариант
        func testBasicJSONEncoding() {

            // Given
            let todoItem = TodoItem(id: "idtest1", text: "Помыть посуду", importance: .important, isDone: false, dateCreation: Date(timeIntervalSince1970: 1234))

            // Act
            guard let todoAsJSON = todoItem.json as? [String: Any] else {
                XCTFail("Failed to convert JSON to [String: Any]")
                return
            }

            // Then
            XCTAssertEqual(todoAsJSON["id"] as? String, "idtest1")
            XCTAssertEqual(todoAsJSON["text"] as? String, "Помыть посуду")
            
            XCTAssertNil(todoAsJSON["deadline"])
            
            let importanceAsString = todoAsJSON["importance"] as! String
            XCTAssertEqual(importanceAsString.convertToImportance(), Importance.important)
            
            XCTAssertEqual(todoAsJSON["isDone"] as? Bool, false)
            XCTAssertEqual(todoAsJSON["dateCreation"] as? String, "1970-01-01 03:20:34")
            XCTAssertNil(todoAsJSON["dateChanging"])
        }
        
    //    Тестируем var json: Any: случай когда, выбрана обычная важность .ordinary.
    //    По ТЗ в этом случае она не должна сохраняться
        func testJSONEncodingWithOrdinaryImportance() {
            // Given
            let todoItem = TodoItem(id: "idtest1", text: "Помыть посуду", importance: .ordinary, isDone: false, dateCreation: Date(timeIntervalSince1970: 1234))

            // Act
            guard let todoAsJSON = todoItem.json as? [String: Any] else {
                XCTFail("Failed to convert JSON to [String: Any]")
                return
            }

            // Then
            XCTAssertEqual(todoAsJSON["id"] as? String, "idtest1")
            XCTAssertEqual(todoAsJSON["text"] as? String, "Помыть посуду")
            
            XCTAssertNil(todoAsJSON["deadline"])
            XCTAssertNil(todoAsJSON["importance"])
            
            XCTAssertEqual(todoAsJSON["isDone"] as? Bool, false)
            XCTAssertEqual(todoAsJSON["dateCreation"] as? String, "1970-01-01 03:20:34")
            XCTAssertNil(todoAsJSON["dateChanging"])
        }
    

}

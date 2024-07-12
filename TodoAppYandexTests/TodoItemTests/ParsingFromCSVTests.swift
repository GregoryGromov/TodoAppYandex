import XCTest
@testable import TodoAppYandex

final class ParsingFromCSVTests: XCTestCase {

    func testCSVParsingWithAllNotEmptyRows() {
//      Given
        let CSVExample = """
        4ocnho43yrpq,write to Misha,unimportant,1970-01-01 03:20:34,false,1970-01-01 03:20:33,1970-01-01 03:20:32
        fu39ubjhaq12,finish the program,important,1970-01-01 03:20:31,true,1970-01-01 03:20:30,1970-01-01 03:20:29
        """

//      Act
        let parsedCSV = TodoItem.parseCSV(CSVExample)!

//      Then
        let item1Right = TodoItem(
            id: "4ocnho43yrpq",
            text: "write to Misha",
            importance: .unimportant,
            deadline: Date(timeIntervalSince1970: 1234),
            isDone: false,
            dateCreation: Date(timeIntervalSince1970: 1233),
            dateChanging: Date(timeIntervalSince1970: 1232)
        )

        let item2Right = TodoItem(
            id: "fu39ubjhaq12",
            text: "finish the program",
            importance: .important,
            deadline: Date(timeIntervalSince1970: 1231),
            isDone: true,
            dateCreation: Date(timeIntervalSince1970: 1230),
            dateChanging: Date(timeIntervalSince1970: 1229)
        )

        XCTAssertEqual(parsedCSV[0], item1Right)
        XCTAssertEqual(parsedCSV[1], item2Right)
    }

    func testCSVParsingWithOnlyRequiredRows() {
//      Given
        let CSVExample = """
        4ocnho43yrpq,write to Misha,unimportant,,false,1970-01-01 03:20:33,
        fu39ubjhaq12,finish the program,important,,true,1970-01-01 03:20:30,
        """

//      Act
        let parsedCSV = TodoItem.parseCSV(CSVExample)!

//      Then
        let item1Right = TodoItem(
            id: "4ocnho43yrpq", text: "write to Misha",
            importance: .unimportant,
            deadline: nil, isDone: false,
            dateCreation: Date(timeIntervalSince1970: 1233),
            dateChanging: nil
        )

        let item2Right = TodoItem(
            id: "fu39ubjhaq12",
            text: "finish the program",
            importance: .important,
            deadline: nil,
            isDone: true,
            dateCreation: Date(timeIntervalSince1970: 1230),
            dateChanging: nil
        )

        XCTAssertEqual(parsedCSV[0], item1Right)
        XCTAssertEqual(parsedCSV[1], item2Right)
    }

    func testCSVParsingDifferentRows() {
//      Given
        let CSVExample = """
                4ocnho43yrpq,write to Misha,unimportant,1970-01-01 03:20:34,false,1970-01-01 03:20:33,
                fu39ubjhaq12,finish the program,ordinary,,true,1970-01-01 03:20:30,1970-01-01 03:20:29
                """

//      Act
        let parsedCSV = TodoItem.parseCSV(CSVExample)!

//      Then
        let item1Right = TodoItem(
            id: "4ocnho43yrpq",
            text: "write to Misha",
            importance: .unimportant,
            deadline: Date(timeIntervalSince1970: 1234),
            isDone: false,
            dateCreation: Date(timeIntervalSince1970: 1233),
            dateChanging: nil
        )

        let item2Right = TodoItem(
            id: "fu39ubjhaq12",
            text: "finish the program",
            importance: .ordinary,
            deadline: nil,
            isDone: true,
            dateCreation: Date(timeIntervalSince1970: 1230),
            dateChanging: Date(timeIntervalSince1970: 1229)
        )

        XCTAssertEqual(parsedCSV[0], item1Right)
        XCTAssertEqual(parsedCSV[1], item2Right)
    }

}

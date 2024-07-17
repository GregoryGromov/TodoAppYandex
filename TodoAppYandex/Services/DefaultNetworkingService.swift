import Foundation

class TestForDefaultNetworkingService {
    let MOCK: [TodoItem] = [
        TodoItem(
            id: "osaID",
            text: "Потсавить будильник",
            importance: .important,
            deadline: nil,
            isDone: false,
            dateCreation: Date(),
            dateChanging: Date(),
            color: "#32892899"
        ),
        TodoItem(
            id: "osaID2",
            text: "Вырастить дерево",
            importance: .important,
            deadline: nil,
            isDone: false,
            dateCreation: Date(),
            dateChanging: Date(),
            color: "#32892899"
        )
    ]

}

class DefaultNetworkingService {

    enum RequestMode {
        case getAll
        case patch
        case getItem
        case post
        case delete
    }

    private let baseURL = "https://hive.mrdekk.ru/todo"
    private let testDeveiceID = "iphoneXSgregory"
    private let token = "Amras"
    
    
    
    
    
    func updateList(with list: [TodoItem]) async throws {

        guard let url = URL(string: baseURL + "/list") else {
            throw NetworkError.URLCreationFailed
        }

        var request = URLRequest(url: url)
        
        request.httpMethod = "PATCH"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.setValue("1", forHTTPHeaderField: "X-Last-Known-Revision")
        request.httpBody = try createHttpBody(list: list)

        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    print("Success: \(httpResponse.statusCode)")
                    if let responseData = try? JSONSerialization.jsonObject(with: data, options: []) {
                        print("Response data: \(responseData)")
                    }
                case 400:
                    throw NetworkError.incorrectRequestFormat
                case 401:
                    throw NetworkError.incorrectAuthorization
                case 404:
                    throw NetworkError.elementNotFound
                case 500:
                    throw NetworkError.serverError
                default:
                    throw NetworkError.unknownError
                }
            }
        } catch {
            throw error
        }
    }
    
    private func createHttpBody(list: [TodoItem]) throws -> Data {
        var listOfElement = [[String: Any]]()

        for element in list {
            guard var decodedElement = element.jsonNetworking as? [String: Any] else {
                throw DataStorageError.convertingDataFailed
            }
            decodedElement[JSONKeys.lastUpdatedBy] = testDeveiceID
            listOfElement.append(decodedElement)
        }

        var httpBodyDict = [String: Any]()
        httpBodyDict[NetworkingKeys.status] = "ok"
        httpBodyDict[NetworkingKeys.list] = listOfElement

        do {
            let httpBody = try JSONSerialization.data(withJSONObject: httpBodyDict, options: [])
            return httpBody
        } catch {
            throw DataStorageError.JSONSerializingFailed
        }
    }
}


//    func setUpReqest(mode: RequestMode, request: inout URLRequest, revision: Int?, list: [TodoItem]?) throws {
//        switch mode {
//        case .getAll:
//            <#code#>
//        case .patch:
//            request.httpMethod = "PATCH"
//            request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
//            request.setValue("1", forHTTPHeaderField: "X-Last-Known-Revision")
//
//            guard let list = list else {
//                return
//            }
//            let httpBody = try createHttpBody(list: list, revision: 3)
//            request.httpBody = httpBody
//        case .getItem:
//            <#code#>
//        case .post:
//            <#code#>
//        case .delete:
//            <#code#>
//        }
//    }

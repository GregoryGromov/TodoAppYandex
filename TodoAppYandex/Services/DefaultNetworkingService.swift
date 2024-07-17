import Foundation

class TestForDefaultNetworkingService {
    let MOCK: [TodoItem] = [
        TodoItem(
            id: "pchelaID2",
            text: "Потсавить будильник",
            importance: .important,
            deadline: nil,
            isDone: false,
            dateCreation: Date(),
            dateChanging: Date(),
            color: "#32892899"
        ),
        TodoItem(
            id: "pchelaID3",
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

//    Получает все элементы списка #1 - OK
    //    TODO: сделать рефакторинг
    func getList() async throws -> [TodoItem] {
        guard let url = URL(string: baseURL + "/list") else {
            throw NetworkError.URLCreationFailed
        }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    //                    print("Success: \(httpResponse.statusCode)")
                    if let responseData = try? JSONSerialization.jsonObject(with: data, options: []),
                       let dictionary = responseData as? [String: Any],
                       let list = dictionary[NetworkingKeys.list] as? [[String: Any]] {
                        var todoItems = [TodoItem]()
                        for element in list {
                            if let todoItem = try TodoItem.parseNetworking(json: element) {
                                todoItems.append(todoItem)
                            }
                        }
                        return todoItems
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

        throw NetworkError.unknownError
    }

//    PATCH обновить спиок #2 - OK
//    удаляет имеющийся и добавляет новый
    func updateList(with list: [TodoItem]) async throws {

        guard let url = URL(string: baseURL + "/list") else {
            throw NetworkError.URLCreationFailed
        }

        var request = URLRequest(url: url)

        request.httpMethod = "PATCH"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.setValue("6", forHTTPHeaderField: "X-Last-Known-Revision")
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

//    GET element #3 - OK
    func getElement(byId id: String) async throws {
        guard let url = URL(string: baseURL + "/list/" + id) else {
            throw NetworkError.URLCreationFailed
        }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")

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

//    POST #4 - ОК
    func addElement(_ todoItem: TodoItem, revision: Int) async throws {
        guard let url = URL(string: baseURL + "/list/") else {
            throw NetworkError.URLCreationFailed
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision") // мб можно и без String() ???
        request.httpBody = try createHttpBody(element: todoItem)

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

    
    
    //    PUT #5
    //    TODO: на данный момент возвращается ошибка 400, хотя формат, кажется правильный. В ТЗ написано, что ошибка 400 может значить "если ревизии не сходятся". Что это значит? Мы ведь даже не передаем никакую revision в это запросе
    func updateElement(byId id: String, with todoItem: TodoItem, revision: Int) async throws {

        guard let url = URL(string: baseURL + "/list/" + id) else {
            throw NetworkError.URLCreationFailed
        }

        var request = URLRequest(url: url)

        request.httpMethod = "PUT"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
        request.httpBody = try createHttpBody(element: todoItem)
        

//        print("REQUSET:", request.httpBody)
//        let x = try? JSONSerialization.jsonObject(with: request.httpBody!, options: [])
//        print(x!)

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

// DELETE #6 - OK
    func deleteElement(byId id: String) async throws {
        guard let url = URL(string: baseURL + "/list/" + id) else {
            throw NetworkError.URLCreationFailed
        }

        print("URL:", baseURL + "/list/" + id)

        var request = URLRequest(url: url)

        request.httpMethod = "DELETE"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.setValue("7", forHTTPHeaderField: "X-Last-Known-Revision")

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

    private func createHttpBody(element: TodoItem) throws -> Data {
        guard var decodedElement = element.jsonNetworking as? [String: Any] else {
            throw DataStorageError.convertingDataFailed
        }
        decodedElement[JSONKeys.lastUpdatedBy] = testDeveiceID

        var httpBodyDict = [String: Any]()
        httpBodyDict[NetworkingKeys.status] = "ok"
        httpBodyDict[NetworkingKeys.element] = decodedElement

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

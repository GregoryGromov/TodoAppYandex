import Foundation

class DefaultNetworkingService {

    enum RequestMode {
        case getAll
        case patch
        case getItem
        case post
        case put
        case delete
    }

    private let baseURL = "https://hive.mrdekk.ru/todo"
    private let testDeveiceID = "iphoneXSgregory"
    private let token = "Amras"
    
//    #1 "Получить список с сервера"
    func getList() async throws -> [TodoItem] {
        let url = try makeURL(forMode: .getAll)
        let request = try makeURLRequest(forMode: .getAll, url: url)

        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            if let todoItems = try handleServerResponse(data: data, response: response, mode: .getAll) as? [TodoItem] {
                return todoItems
            }
        } catch {
            throw error
        }
        
        throw NetworkError.unknownError
    }

//    #2 "Обновить список на сервере"
    func updateList(with list: [TodoItem], revision: Int) async throws -> [TodoItem] {
        let url = try makeURL(forMode: .patch)
        let request = try makeURLRequest(forMode: .patch, url: url, revision: revision, list: list)

        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            if let todoItems = try handleServerResponse(data: data, response: response, mode: .patch) as? [TodoItem] {
                return todoItems
            }
        } catch {
            throw error
        }
        
        throw NetworkError.unknownError
    }

//    #3 "Получить элемент списка"
    func getElement(byId id: String) async throws -> TodoItem {
        let url = try makeURL(forMode: .getItem, elementId: id)
        let request = try makeURLRequest(forMode: .getItem, url: url)

        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            if let todoItem = try handleServerResponse(data: data, response: response, mode: .getItem) as? TodoItem {
                return todoItem
            }
        } catch {
            throw error
        }
        
        throw NetworkError.unknownError
    }

//    #4 "Добавить элемент списка"
    func addElement(_ todoItem: TodoItem, revision: Int) async throws -> TodoItem {
        let url = try makeURL(forMode: .post)
        let request = try makeURLRequest(forMode: .post, url: url, revision: revision, element: todoItem)

        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            if let todoItem = try handleServerResponse(data: data, response: response, mode: .post) as? TodoItem {
                return todoItem
            }
        } catch {
            throw error
        }
        
        throw NetworkError.unknownError
    }

//    #5 "Изменить элемент списка"
    func updateElement(byId id: String, with todoItem: TodoItem, revision: Int) async throws -> TodoItem {
        let url = try makeURL(forMode: .put, elementId: id)
        let request = try makeURLRequest(forMode: .put, url: url, revision: revision, element: todoItem)

        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            if let todoItem = try handleServerResponse(data: data, response: response, mode: .put) as? TodoItem {
                return todoItem
            }
        } catch {
            throw error
        }
        
        throw NetworkError.unknownError
    }
    
    
//    #6 "Удалить элемент списка"
    func deleteElement(byId id: String, revision: Int) async throws -> TodoItem {
        let url = try makeURL(forMode: .delete, elementId: id)
        let request = try makeURLRequest(forMode: .delete, url: url, revision: revision)

        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            if let todoItem = try handleServerResponse(data: data, response: response, mode: .delete) as? TodoItem {
                return todoItem
            }
        } catch {
            throw error
        }
        
        throw NetworkError.unknownError
    }
    
    private func isRequestSuccessful(response: HTTPURLResponse) -> Bool {
        switch response.statusCode {
        case 200...299:
            return true
        default:
            return false
        }
        
    }
    
    private func handleErrors(response: HTTPURLResponse) throws {
        switch response.statusCode {
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
    
    private func handleServerResponse(data: Data, response: URLResponse, mode: RequestMode) throws -> Any {
        if let httpResponse = response as? HTTPURLResponse {
            if isRequestSuccessful(response: httpResponse) {
                switch mode {
                case .getAll, .patch:
                    let todoItems = try handleMultipleDataResponce(data: data)
                    return todoItems
                case .getItem, .post, .delete, .put:
                    let todoItem = try handleSingleDataResponce(data: data)
                    return todoItem
                }
            } else {
                try handleErrors(response: httpResponse)
            }
        }
        throw NetworkError.unknownError
    }
    
    private func handleMultipleDataResponce(data: Data) throws -> [TodoItem] {
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
        throw DataStorageError.JSONSerializingFailed
    }
    
    private func handleSingleDataResponce(data: Data) throws -> TodoItem {
        if let responseData = try? JSONSerialization.jsonObject(with: data, options: []),
           let dictionary = responseData as? [String: Any],
           let element = dictionary[NetworkingKeys.element] as? [String: Any] {
            if let todoItem = try TodoItem.parseNetworking(json: element) {
                return todoItem
            }
        }
        throw DataStorageError.JSONSerializingFailed
    }
    
    private func makeURL(forMode mode: RequestMode, elementId: String? = nil) throws -> URL {
        switch mode {
        case .getAll, .patch, .post:
            guard let url = URL(string: baseURL + "/list") else {
                throw NetworkError.URLCreationFailed
            }
            return url
        case .getItem, .put, .delete:
            if let id = elementId {
                guard let url = URL(string: baseURL + "/list/" + id) else {
                    throw NetworkError.URLCreationFailed
                }
                return url
            }
        }
        throw NetworkError.unknownError
    }
    
    private func makeURLRequest(forMode mode: RequestMode, url: URL, revision: Int? = nil, list: [TodoItem]? = nil, element: TodoItem? = nil) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        switch mode {
        case .getAll:
            request.httpMethod = "GET"
        case .patch:
            request.httpMethod = "PATCH"
            if let revision = revision,
            let list = list {
                request.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
                request.httpBody = try createHttpBody(list: list)
            }
        case .getItem:
            request.httpMethod = "GET"
            request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        case .post:
            request.httpMethod = "POST"
            if let revision = revision,
            let element = element {
                print("Зашли")
                request.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
                request.httpBody = try createHttpBody(element: element)
            }
        case .put:
            request.httpMethod = "PUT"
            if let revision = revision,
            let element = element {
                request.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
                request.httpBody = try createHttpBody(element: element)
            }
        case .delete:
            request.httpMethod = "DELETE"
            print("Здеся 1.5")
            if let revision = revision {
                print("Здеся 2")
                request.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
            }
        }
        
        return request
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





//
////    PATCH обновить спиок #2 - OK
////    удаляет имеющийся и добавляет новый
//    func updateList(with list: [TodoItem], revision: Int) async throws -> [TodoItem] {
//
//        guard let url = URL(string: baseURL + "/list") else {
//            throw NetworkError.URLCreationFailed
//        }
//
//        var request = URLRequest(url: url)
//
//        request.httpMethod = "PATCH"
//        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
//        request.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
//        request.httpBody = try createHttpBody(list: list)
//
//        do {
//            let (data, response) = try await URLSession.shared.dataTask(for: request)
//            if let httpResponse = response as? HTTPURLResponse {
//                switch httpResponse.statusCode {
//                case 200...299:
//                    if let responseData = try? JSONSerialization.jsonObject(with: data, options: []),
//                       let dictionary = responseData as? [String: Any],
//                       let list = dictionary[NetworkingKeys.list] as? [[String: Any]] {
//                        var todoItems = [TodoItem]()
//                        for element in list {
//                            if let todoItem = try TodoItem.parseNetworking(json: element) {
//                                todoItems.append(todoItem)
//                            }
//                        }
//                        return todoItems
//                    }
//                case 400:
//                    throw NetworkError.incorrectRequestFormat
//                case 401:
//                    throw NetworkError.incorrectAuthorization
//                case 404:
//                    throw NetworkError.elementNotFound
//                case 500:
//                    throw NetworkError.serverError
//                default:
//                    throw NetworkError.unknownError
//                }
//            }
//        } catch {
//            throw error
//        }
//        
//        throw NetworkError.unknownError
//    }
//
////    GET element #3 - OK
//    func getElement(byId id: String) async throws -> TodoItem {
//        guard let url = URL(string: baseURL + "/list/" + id) else {
//            throw NetworkError.URLCreationFailed
//        }
//
//        var request = URLRequest(url: url)
//
//        request.httpMethod = "GET"
//        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
//
//        do {
//            let (data, response) = try await URLSession.shared.dataTask(for: request)
//            if let httpResponse = response as? HTTPURLResponse {
//                switch httpResponse.statusCode {
//                case 200...299:
//                    print("Success: \(httpResponse.statusCode)")
//                    if let responseData = try? JSONSerialization.jsonObject(with: data, options: []),
//                       let dictionary = responseData as? [String: Any],
//                       let element = dictionary[NetworkingKeys.element] as? [String: Any] {
//                        if let todoItem = try TodoItem.parseNetworking(json: element) {
//                            return todoItem
//                        }
//                    }
//                case 400:
//                    throw NetworkError.incorrectRequestFormat
//                case 401:
//                    throw NetworkError.incorrectAuthorization
//                case 404:
//                    throw NetworkError.elementNotFound
//                case 500:
//                    throw NetworkError.serverError
//                default:
//                    throw NetworkError.unknownError
//                }
//            }
//        } catch {
//            throw error
//        }
//        
//        throw NetworkError.unknownError
//    }
//
////    POST #4 - ОК
//    func addElement(_ todoItem: TodoItem, revision: Int) async throws -> TodoItem {
//        guard let url = URL(string: baseURL + "/list") else {
//            throw NetworkError.URLCreationFailed
//        }
//
//        var request = URLRequest(url: url)
//
//        request.httpMethod = "POST"
//        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
//        request.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
//        request.httpBody = try createHttpBody(element: todoItem)
//
//        do {
//            let (data, response) = try await URLSession.shared.dataTask(for: request)
//            if let httpResponse = response as? HTTPURLResponse {
//                switch httpResponse.statusCode {
//                case 200...299:
//                    if let responseData = try? JSONSerialization.jsonObject(with: data, options: []),
//                       let dictionary = responseData as? [String: Any],
//                       let element = dictionary[NetworkingKeys.element] as? [String: Any] {
//                        if let todoItem = try TodoItem.parseNetworking(json: element) {
//                            return todoItem
//                        }
//                    }
//                case 400:
//                    throw NetworkError.incorrectRequestFormat
//                case 401:
//                    throw NetworkError.incorrectAuthorization
//                case 404:
//                    throw NetworkError.elementNotFound
//                case 500:
//                    throw NetworkError.serverError
//                default:
//                    throw NetworkError.unknownError
//                }
//            }
//        } catch {
//            throw error
//        }
//        
//        throw NetworkError.unknownError
//    }
//
//    //    PUT #5
//    func updateElement(byId id: String, with todoItem: TodoItem, revision: Int) async throws -> TodoItem {
//
//        guard let url = URL(string: baseURL + "/list/" + id) else {
//            throw NetworkError.URLCreationFailed
//        }
//
//        var request = URLRequest(url: url)
//
//        request.httpMethod = "PUT"
//        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
//        request.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
//        request.httpBody = try createHttpBody(element: todoItem)
//
//        do {
//            let (data, response) = try await URLSession.shared.dataTask(for: request)
//            if let httpResponse = response as? HTTPURLResponse {
//                switch httpResponse.statusCode {
//                case 200...299:
//                    print("Success: \(httpResponse.statusCode)")
//                    if let responseData = try? JSONSerialization.jsonObject(with: data, options: []),
//                       let dictionary = responseData as? [String: Any],
//                       let element = dictionary[NetworkingKeys.element] as? [String: Any] {
//                        if let todoItem = try TodoItem.parseNetworking(json: element) {
//                            return todoItem
//                        }
//                    }
//                case 400:
//                    throw NetworkError.incorrectRequestFormat
//                case 401:
//                    throw NetworkError.incorrectAuthorization
//                case 404:
//                    throw NetworkError.elementNotFound
//                case 500:
//                    throw NetworkError.serverError
//                default:
//                    throw NetworkError.unknownError
//                }
//            }
//        } catch {
//            throw error
//        }
//        
//        throw NetworkError.unknownError
//    }
//
//// DELETE #6 - OK
//    func deleteElement(byId id: String, revision: Int) async throws -> TodoItem {
//        guard let url = URL(string: baseURL + "/list/" + id) else {
//            throw NetworkError.URLCreationFailed
//        }
//
//        print("URL:", baseURL + "/list/" + id)
//
//        var request = URLRequest(url: url)
//
//        request.httpMethod = "DELETE"
//        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
//        request.setValue(String(revision), forHTTPHeaderField: "X-Last-Known-Revision")
//
//        do {
//            let (data, response) = try await URLSession.shared.dataTask(for: request)
//            if let httpResponse = response as? HTTPURLResponse {
//                switch httpResponse.statusCode {
//                case 200...299:
//                    print("Success: \(httpResponse.statusCode)")
//                    if let responseData = try? JSONSerialization.jsonObject(with: data, options: []),
//                       let dictionary = responseData as? [String: Any],
//                       let element = dictionary[NetworkingKeys.element] as? [String: Any] {
//                        if let todoItem = try TodoItem.parseNetworking(json: element) {
//                            return todoItem
//                        }
//                    }
//                case 400:
//                    throw NetworkError.incorrectRequestFormat
//                case 401:
//                    throw NetworkError.incorrectAuthorization
//                case 404:
//                    throw NetworkError.elementNotFound
//                case 500:
//                    throw NetworkError.serverError
//                default:
//                    throw NetworkError.unknownError
//                }
//            }
//        } catch {
//            throw error
//        }
//        
//        throw NetworkError.unknownError
//    }
//
//    private func createHttpBody(list: [TodoItem]) throws -> Data {
//        var listOfElement = [[String: Any]]()
//
//        for element in list {
//            guard var decodedElement = element.jsonNetworking as? [String: Any] else {
//                throw DataStorageError.convertingDataFailed
//            }
//            decodedElement[JSONKeys.lastUpdatedBy] = testDeveiceID
//            listOfElement.append(decodedElement)
//        }
//
//        var httpBodyDict = [String: Any]()
//        httpBodyDict[NetworkingKeys.status] = "ok"
//        httpBodyDict[NetworkingKeys.list] = listOfElement
//
//        do {
//            let httpBody = try JSONSerialization.data(withJSONObject: httpBodyDict, options: [])
//            return httpBody
//        } catch {
//            throw DataStorageError.JSONSerializingFailed
//        }
//    }
//
//    private func createHttpBody(element: TodoItem) throws -> Data {
//        guard var decodedElement = element.jsonNetworking as? [String: Any] else {
//            throw DataStorageError.convertingDataFailed
//        }
//        decodedElement[JSONKeys.lastUpdatedBy] = testDeveiceID
//
//        var httpBodyDict = [String: Any]()
//        httpBodyDict[NetworkingKeys.status] = "ok"
//        httpBodyDict[NetworkingKeys.element] = decodedElement
//
//        do {
//            let httpBody = try JSONSerialization.data(withJSONObject: httpBodyDict, options: [])
//            return httpBody
//        } catch {
//            throw DataStorageError.JSONSerializingFailed
//        }
//    }
//}

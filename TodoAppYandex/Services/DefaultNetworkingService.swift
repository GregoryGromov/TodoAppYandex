import Foundation

class DefaultNetworkingService {

    static let shared = DefaultNetworkingService()

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

// MARK: - #1 "Получить список с сервера"

    func getList() async throws -> (list: [TodoItem], revision: Int) {
        do {
            let url = try makeURL(forMode: .getAll)
            let request = try makeURLRequest(forMode: .getAll, url: url)

            let (data, response) = try await URLSession.shared.dataTask(for: request)
            if let (todoItems, revision) = try handleServerResponse(data: data, response: response, mode: .getAll) as? ([TodoItem], Int) {
                return (todoItems, revision)
            }
        } catch {
            throw error
        }

        throw NetworkError.unknownError
    }

// MARK: - #2 "Обновить список на сервере"

    func updateList(with list: [TodoItem], revision: Int) async throws -> (list: [TodoItem], revision: Int) {

        let url = try makeURL(forMode: .patch)
        let request = try makeURLRequest(forMode: .patch, url: url, revision: revision, list: list)

        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            if let (todoItems, revision) = try handleServerResponse(data: data, response: response, mode: .patch) as? ([TodoItem], Int) {
                return (todoItems, revision)
            }
        } catch {
            throw error
        }

        throw NetworkError.unknownError
    }

// MARK: - #3 "Получить элемент списка"

    func getElement(byId id: String) async throws -> (item: TodoItem, revision: Int) {
        let url = try makeURL(forMode: .getItem, elementId: id)
        let request = try makeURLRequest(forMode: .getItem, url: url)

        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            if let (todoItem, revision) = try handleServerResponse(data: data, response: response, mode: .getItem) as? (TodoItem, Int) {
                return (todoItem, revision)
            }
        } catch {
            throw error
        }

        throw NetworkError.unknownError
    }

// MARK: - #4 "Добавить элемент списка"

    func addElement(_ todoItem: TodoItem, revision: Int) async throws -> (item: TodoItem, revision: Int) {
        let url = try makeURL(forMode: .post)
        let request = try makeURLRequest(forMode: .post, url: url, revision: revision, element: todoItem)

        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            if let (todoItem, revision) = try handleServerResponse(data: data, response: response, mode: .post) as? (TodoItem, Int) {
                return (todoItem, revision)
            }
        } catch {
            throw error
        }

        throw NetworkError.unknownError
    }

// MARK: - #5 "Изменить элемент списка"

    func updateElement(byId id: String, with todoItem: TodoItem, revision: Int) async throws -> (item: TodoItem, revision: Int) {
        let url = try makeURL(forMode: .put, elementId: id)
        let request = try makeURLRequest(forMode: .put, url: url, revision: revision, element: todoItem)

        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            if let (todoItem, revision) = try handleServerResponse(data: data, response: response, mode: .put) as? (TodoItem, Int) {
                return (todoItem, revision)
            }
        } catch {
            throw error
        }

        throw NetworkError.unknownError
    }

// MARK: - #6 "Удалить элемент списка"

    func deleteElement(byId id: String, revision: Int) async throws -> (item: TodoItem, revision: Int) {
        let url = try makeURL(forMode: .delete, elementId: id)
        let request = try makeURLRequest(forMode: .delete, url: url, revision: revision)

        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            if let (todoItem, revision) = try handleServerResponse(data: data, response: response, mode: .delete) as? (TodoItem, Int) {
                return (todoItem, revision)
            }
        } catch {
            throw error
        }

        throw NetworkError.unknownError
    }

// MARK: - Handling response status

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

// MARK: - Handling response

    private func handleServerResponse(data: Data, response: URLResponse, mode: RequestMode) throws -> Any {
        if let httpResponse = response as? HTTPURLResponse {
            if isRequestSuccessful(response: httpResponse) {
                switch mode {
                case .getAll, .patch:
                    let (todoItems, revision) = try handleMultipleDataResponce(data: data)
                    return (todoItems, revision)
                case .getItem, .post, .delete, .put:
                    let (todoItem, revision) = try handleSingleDataResponce(data: data)
                    return (todoItem, revision)
                }
            } else {
                try handleErrors(response: httpResponse)
            }
        }
        throw NetworkError.unknownError
    }

    private func handleMultipleDataResponce(data: Data) throws -> (list: [TodoItem], revision: Int) {
        if let responseData = try? JSONSerialization.jsonObject(with: data, options: []),
           let dictionary = responseData as? [String: Any],
           let list = dictionary[NetworkingKeys.list] as? [[String: Any]],
           let revision = dictionary[NetworkingKeys.revision] as? Int {
            var todoItems = [TodoItem]()
            for element in list {
                if let todoItem = try TodoItem.parseNetworking(json: element) {
                    todoItems.append(todoItem)
                }
            }
            return (todoItems, revision)
        }
        throw DataStorageError.JSONSerializingFailed
    }

    private func handleSingleDataResponce(data: Data) throws -> (item: TodoItem, revision: Int) {
        if let responseData = try? JSONSerialization.jsonObject(with: data, options: []),
           let dictionary = responseData as? [String: Any],
           let element = dictionary[NetworkingKeys.element] as? [String: Any],
           let revision = dictionary[NetworkingKeys.revision] as? Int {
            if let todoItem = try TodoItem.parseNetworking(json: element) {
                return (todoItem, revision)
            }
        }
        throw DataStorageError.JSONSerializingFailed
    }

// MARK: - Request creation

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
        request.setValue("Bearer " + token, forHTTPHeaderField: BackendHTTPHeaderField.authorization)

        switch mode {
        case .getAll:
            request.httpMethod = "GET"
        case .patch:
            request.httpMethod = "PATCH"
            if let revision = revision,
            let list = list {
                request.setValue(String(revision), forHTTPHeaderField: BackendHTTPHeaderField.lastKnownRevision)
                request.httpBody = try createHttpBody(list: list)
            }
        case .getItem:
            request.httpMethod = "GET"
        case .post:
            request.httpMethod = "POST"
            if let revision = revision,
            let element = element {
                request.setValue(String(revision), forHTTPHeaderField: BackendHTTPHeaderField.lastKnownRevision)
                request.setValue(String(50), forHTTPHeaderField: BackendHTTPHeaderField.generateFails)

                request.httpBody = try createHttpBody(element: element)
            }
        case .put:
            request.httpMethod = "PUT"
            if let revision = revision,
            let element = element {
                request.setValue(String(revision), forHTTPHeaderField: BackendHTTPHeaderField.lastKnownRevision)

                request.setValue(String(50), forHTTPHeaderField: BackendHTTPHeaderField.generateFails)
                request.httpBody = try createHttpBody(element: element)
            }
        case .delete:
            request.httpMethod = "DELETE"
            if let revision = revision {
                request.setValue(String(revision), forHTTPHeaderField: BackendHTTPHeaderField.lastKnownRevision)
                request.setValue(String(50), forHTTPHeaderField: BackendHTTPHeaderField.generateFails)
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

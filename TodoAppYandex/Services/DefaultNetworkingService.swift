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

//    private let baseURL = "https://beta.mrdekk.ru/todo"
    private let baseURL = "https://hive.mrdekk.ru/todo"

    private let testDeveiceID = "iphoneXSgregory"

//    функция добавления массива todoItem
    func postTODOs() async throws {
        guard let url = URL(string: baseURL + "/list") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"

        let token = "Amras"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.setValue("1", forHTTPHeaderField: "X-Last-Known-Revision")

        let elements = TestForDefaultNetworkingService().MOCK
        var listOfElement = [[String: Any]]()
        for element in elements {
            guard var decodedElement = element.jsonNetworking as? [String: Any] else { return }
            decodedElement[JSONKeys.lastUpdatedBy] = testDeveiceID
            listOfElement.append(decodedElement)
        }

        var httpBody = [String: Any]()
        httpBody[NetworkingKeys.status] = "ok"
        httpBody[NetworkingKeys.list] = listOfElement
        httpBody[NetworkingKeys.revision] = "1"

        for key in httpBody.keys {
            print(key)
            print(httpBody[key]!)
        }

        // Сериализуем словарь в Data
        do {
            let httpBodyData = try JSONSerialization.data(withJSONObject: httpBody, options: [])
            request.httpBody = httpBodyData
        } catch {
            print("Error serializing JSON: \(error)")
        }

        do {
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            // обрабатываем результат
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    print("Success: \(httpResponse.statusCode)")
                    if let responseData = try? JSONSerialization.jsonObject(with: data, options: []) {
                        print("Response data: \(responseData)")
                    }
                default:
                    print("Request failed with status code: \(httpResponse.statusCode)")
                }
            }
        } catch {
            print("Error making PATCH request: \(error)")

        }
    }

}

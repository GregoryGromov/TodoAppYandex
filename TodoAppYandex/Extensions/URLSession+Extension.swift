//
//  URLSession+Extension.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 12.07.2024.
//

import Foundation

extension URLSession {
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        let cancellableStorage = CancellablesStorage()

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let task = self.dataTask(with: urlRequest) { data, response, _ in

                    if Task.isCancelled {
                        continuation.resume(throwing: CancellationError())
                        return
                    }

                    guard let data = data, let response = response else {
                        return
                    }

                    continuation.resume(returning: (data, response))
                }

                task.resume()

                cancellableStorage.add(task as Cancellable)

                if Task.isCancelled {
                    task.cancel()
                    continuation.resume(throwing: CancellationError())
                }
            }
        } onCancel: {
            cancellableStorage.cancel()
        }
    }
}

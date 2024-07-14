//
//  FileManagerService.swift
//  ToDoAppYandex
//
//  Created by Григорий Громов on 19.06.2024.
//

import Foundation

class FileManagerService {

    static let shared = FileManagerService()

    func writeDataToFile(withName fileName: String, data: Any) throws {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])

            guard let path = try getPathForFile(withName: fileName) else { return }

            do {
                try jsonData.write(to: path)
            } catch {
                throw DataStorageError.writingToFileFailed
            }
        } catch {
            throw DataStorageError.convertingDataFailed
        }
    }

    func readDataFromFile(withName fileName: String) throws -> Data? {
        guard let path = try getPathForFile(withName: fileName) else { return nil }

        if FileManager.default.fileExists(atPath: path.path) {
            if let data = try? Data(contentsOf: path) {
                return data
            } else {
                throw DataStorageError.readingFromFileFailed
            }
        } else {
            throw DataStorageError.invalidPath
        }
    }

    private func getPathForFile(withName fileName: String) throws -> URL? {
        guard
            let path = FileManager
                .default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent("\(fileName)")
        else {
            throw DataStorageError.pathCreationFailed
        }

        return path
    }
}

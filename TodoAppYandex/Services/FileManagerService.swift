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

            guard let path = getPathForFile(withName: fileName) else { return }

            do {
                try jsonData.write(to: path)
            } catch {
                print("Error saving data to file")
                throw error
            }
        } catch {
            print("Error converting data from Any to Data")
            throw error
        }
    }

    func readDataFromFile(withName fileName: String) -> Data? {
        guard let path = getPathForFile(withName: fileName) else { return nil }

        if FileManager.default.fileExists(atPath: path.path) {
            if let data = try? Data(contentsOf: path) {
                print("Success reading")
                return data
            } else {
                print("Error reading data from file")
                return nil
            }
        } else {
            print("Error: there no file with this name")
            return nil
        }
    }

    private func getPathForFile(withName fileName: String) -> URL? {
        guard
            let path = FileManager
                .default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent("\(fileName)")
        else {
            print("Error getting path")
            return nil
        }

        return path
    }
}

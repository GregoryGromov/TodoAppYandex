//
//  Errors.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 14.07.2024.
//

import Foundation

enum DataStorageError: Error {
    case writingToFileFailed
    case savingToFileFailed
    case readingFromFileFailed

    case convertingDataFailed

    case invalidPath
    case pathCreationFailed

    case invalidCSVFormat
}

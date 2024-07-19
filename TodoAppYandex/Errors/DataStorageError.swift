import Foundation

enum DataStorageError: Error {
    case writingToFileFailed
    case savingToFileFailed
    case readingFromFileFailed

    case convertingDataFailed

    case invalidPath
    case pathCreationFailed

    case invalidCSVFormat

    case JSONSerializingFailed
}

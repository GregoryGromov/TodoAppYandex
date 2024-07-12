import Foundation

extension String {
    func convertToDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        if let decodedDate = dateFormatter.date(from: self) {
            return decodedDate
        }
        return nil
    }

    func convertToImportance() -> Importance? {
        if let importance = Importance(rawValue: self) {
            return importance
        } else {
            return nil
        }
    }
}

import Foundation

extension Date {
    func convertToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: self)

        return dateString
    }

    func convertToUnixTimestamp() -> Int64 {
        return Int64(self.timeIntervalSince1970)
    }

    var dayMonthYear: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        return dateFormatter.string(from: self)
    }

    var dayMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        return dateFormatter.string(from: self)
    }

}

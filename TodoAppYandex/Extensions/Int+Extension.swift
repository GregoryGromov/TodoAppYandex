import Foundation

extension Int {
    func toDate() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(self))
    }
}

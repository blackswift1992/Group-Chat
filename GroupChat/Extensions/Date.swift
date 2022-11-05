import Foundation

extension Date {
    static func getTimeFromMillis(_ ms: Double, withFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        let dateObject = Date(timeIntervalSince1970: TimeInterval(ms))

        return dateFormatter.string(from: dateObject)
    }
}


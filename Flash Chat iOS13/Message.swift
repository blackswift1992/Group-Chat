import Foundation

struct Message: TableCell {
    let row: Int
    let id: String
    let timestamp: String
    let userId: String
    let userFirstName: String
    let body: String
    let isEdited: String
    let userRGBColor: String
}

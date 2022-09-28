import Foundation
import FirebaseFirestoreSwift

struct MessageData: Codable {
    @DocumentID var documentId: String?
    let date: String
    let userId: String
    let userFirstName: String
    var textBody: String
    var isEdited: String
    let userRGBColor: String
}

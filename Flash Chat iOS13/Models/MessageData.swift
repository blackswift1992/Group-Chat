import Foundation
import FirebaseFirestoreSwift

struct MessageData: Codable {
    @DocumentID var documentId: String?
    let date: String
    let userId: String
    let userFirstName: String
    let textBody: String
    let isEdited: String
    let userRGBColor: String
}

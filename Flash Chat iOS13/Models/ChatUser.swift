import Foundation
import FirebaseFirestoreSwift

struct ChatUser: Codable {
    let userId: String
    let userEmail: String
    let firstName: String
    let lastName: String
    let avatarURL: String
    let userRGBColor: String
}

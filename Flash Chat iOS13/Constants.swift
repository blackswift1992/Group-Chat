struct K {
    static let appName = "⚡️GroupChat"
    
    struct Segue {
        static let signUpToChat = "SignUpToChat"
        static let logInToChat = "LogInToChat"
        static let logInToNewUserData = "LogInToNewUserData"
        static let chatToEditMenu = "ChatToEditMenu"
        static let chatToNewUserData = "ChatToNewUserData"
        static let chatToCancelEdit = "ChatToCancelEdit"
        static let signUpToNewUserData = "SignUpToNewUserData"
        static let newUserDataToChat = "NewUserDataToChat"
        static let chatToUserInfo = "ChatToUserInfo"
        static let userInfoToDeleteAccountWarning = "UserInfoToDeleteAccountWarning"
    }
    
    struct FStore {
        static let usersCollection = "users"
        static let messagesCollection = "messages"
        static let avatarsCollection = "avatars"
        
        static let userIdField = "userId"
        static let userEmailField = "userEmail"
        static let userFirstNameField = "userFirstName"
        static let firstNameField = "firstName"
        static let lastNameField = "lastName"
        static let textBodyField = "textBody"
        static let dateField = "date"
        static let isEdited = "isEdited"
        static let avatarURLField = "avatarURL"
        static let userRGBColorField = "userRGBColor"
    }
    
    struct TableCell {
        static let senderNibIdentifier = "ReusableSenderCell"
        static let senderNibName = "SenderMessageCell"
        
        static let receiverNibIdentifier = "ReusableReceiverCell"
        static let receiverNibName = "ReceiverMessageCell"
        
        static let greetingNibIdentifier = "ReusableGreetingCell"
        static let greetingNibName = "GreetingTableCell"
    }
    
    struct Image {
        static let defaultAvatar = "DefaultAvatar"
        static let defaultGroupAvatar = "DefaultGroupAvatar"
        static let jpegType = "image/jpeg"
    }
    
    struct Date {
        static let messageTimestampFormat = "HH:mm"
    }
    
    struct Case {
        static let no = "no"
        static let yes = "yes"
        static let unknown = "unknown"
        static let emptyString = ""
    }
}


struct K {
    static let appName = "⚡️GroupChat"
    
    
    struct Segue {
        static let signUpToNewUserData = "SignUpToNewUserData"
        
        static let logInToChat = "LogInToChat"
        static let logInToNewUserData = "LogInToNewUserData"
        
        static let newUserDataToChat = "NewUserDataToChat"
        
        static let chatToNewUserData = "ChatToNewUserData"
        
        static let chatToEditMenu = "ChatToEditMenu"
        static let chatToEditMessageWarning = "ChatToEditMessageWarning"
        static let chatToUserMenu = "ChatToUserMenu"
        
        static let userMenuToDeleteAccountWarning = "UserMenuToDeleteAccountWarning"
    }
    
    
    struct FStore {
        static let usersCollection = "users"
        static let messagesCollection = "messages"
        static let avatarsCollection = "avatars"
        
        static let userIdField = "userId"
        static let textBodyField = "textBody"
        static let isEdited = "isEdited"
        static let dateField = "date"
        static let avatarURLField = "avatarURL"
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
        static let jpegType = "image/jpeg"
    }
    
    
    struct Date {
        static let messageTimestampFormat = "HH:mm"
    }
    
    
    struct Case {
        static let no = "no"
        static let yes = "yes"
        static let emptyString = ""
    }
}


struct K {
    static let appName = "⚡️GroupChat"
    
    struct Segue {
        static let signUpToChat = "SignUpToChat"
        static let logInToChat = "LogInToChat"
        static let chatToEditMenu = "ChatToEditMenu"
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
        static let getFormat = "yyyy-MM-dd HH:mm:ss Z"
        static let printFormat = "HH:mm"
    }
    
    struct Case {
        static let no = "no"
        static let yes = "yes"
        static let unknown = "unknown"
        static let emptyString = ""
    }
    
    struct BrandColors {
        static let blue = "BrandBlue"
        static let darkGray = "BrandDarkGray"
        static let darkMint = "BrandDarkMint"
        static let gray = "BrandGray"
        static let gray3 = "BrandGray3"
        static let gray5 = "BrandGray5"
        static let gray6 = "BrandGray6"
        static let lighBlue = "BrandLightBlue"
        static let mint = "BrandMint"
        static let lightMint = "BrandLightMint"
        static let red = "BrandRed"
    }
    
    struct BrandFonts {
        static let avenirNextHeavy = "Avenir Next Heavy"
    }
}


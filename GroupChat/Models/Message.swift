import UIKit

struct Message: TableCell {
    let cellRow: Int
    let data: MessageData
    
    var userColor: UIColor {
        UIColor.getColorFromRGBString(data.userRGBColor)
    }
    
    var timestamp: String {
        guard let msDouble = Double(data.date) else {
            return K.Case.emptyString
        }
        
        var timestamp = Date.getTimeFromMillis(msDouble, withFormat: K.Date.messageTimestampFormat)
        
        timestamp = (data.isEdited == K.Case.yes ? "edited " : K.Case.emptyString) + timestamp
        
        return timestamp
    }
}

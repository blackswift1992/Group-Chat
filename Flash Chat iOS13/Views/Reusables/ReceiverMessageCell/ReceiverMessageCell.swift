import UIKit

class ReceiverMessageCell: UITableViewCell {
    @IBOutlet private weak var messageBubble: UIView!
    @IBOutlet private weak var firstNameLabel: UILabel!
    @IBOutlet private weak var messageBodyLabel: UILabel!
    @IBOutlet private weak var timestampLabel: UILabel!
    @IBOutlet private weak var messageButton: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        customizeViewElements()
    }

    
    func setReceiverMessageCellData(_ message: Message) {
        firstNameLabel.text = message.data.userFirstName
        messageBodyLabel.text = message.data.textBody
        
        timestampLabel.text = (message.data.isEdited == K.Case.yes ? "edited " : K.Case.emptyString) + message.timestamp

        firstNameLabel.textColor = UIColor.getColorFromRGBString(message.data.userRGBColor)
    }


    private func customizeViewElements() {
            let cornerRadius = messageBubble.frame.size.height / 2.30
            messageBubble.layer.cornerRadius = cornerRadius
            messageButton.layer.cornerRadius = cornerRadius
            messageButton.setTitle(K.Case.emptyString, for: .normal)
    }
}

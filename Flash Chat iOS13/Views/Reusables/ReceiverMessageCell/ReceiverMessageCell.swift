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

    
    func setReceiverMessageCellData(userColor: UIColor, userFirstName: String, body: String, timestamp: String) {
        firstNameLabel.textColor = userColor
        firstNameLabel.text = userFirstName
        messageBodyLabel.text = body
        timestampLabel.text = timestamp
    }


    private func customizeViewElements() {
            let cornerRadius = messageBubble.frame.size.height / 2.30
            messageBubble.layer.cornerRadius = cornerRadius
            messageButton.layer.cornerRadius = cornerRadius
            messageButton.setTitle(K.Case.emptyString, for: .normal)
    }
}

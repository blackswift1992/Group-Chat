import UIKit
import AudioToolbox

protocol SenderMessageCellDelegate: AnyObject {
    func messageSelected(_ messageCell: SenderMessageCell, selectedMessage: Message)
}


class SenderMessageCell: UITableViewCell {
    @IBOutlet private weak var messageBubble: UIView!
    @IBOutlet private weak var messageTail: UIImageView!
    @IBOutlet private weak var messageBodyLabel: UILabel!
    @IBOutlet private weak var timestampLabel: UILabel!
    @IBOutlet private weak var messageButton: UIButton!
    
    weak var delegate: SenderMessageCellDelegate?

    private var senderMessage: Message?

    override func awakeFromNib() {
        super.awakeFromNib()
        customizeViewElements()
    }
}


//MARK: - Public methods


extension SenderMessageCell {
    func setData(_ message: Message) {
        senderMessage = message
        messageBodyLabel.text = message.data.textBody
        timestampLabel.text = message.timestamp
    }
}


//MARK: - Private methods


private extension SenderMessageCell {
    func setMessageColor(_ color: UIColor?) {
        messageBubble.backgroundColor = color
        messageTail.tintColor = color
    }
    
    @objc func selectMessageBubble(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            setMessageColor(UIColor.brandDarkMint)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        case .ended:
            setMessageColor(UIColor.brandMint)
            guard let safeSenderMessage = self.senderMessage else { return }
            delegate?.messageSelected(self, selectedMessage: safeSenderMessage)
        default:
            return
        }
    }
}


//MARK: - Set up methods


private extension SenderMessageCell {
    func customizeViewElements() {
        let cornerRadius = messageBubble.frame.size.height / 2.30
        messageBubble.layer.cornerRadius = cornerRadius
        messageButton.layer.cornerRadius = cornerRadius
        messageButton.setTitle(K.Case.emptyString, for: .normal)
        setGestureRecognizerToMessageBubble()
    }
    
    func setGestureRecognizerToMessageBubble() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(selectMessageBubble))
        longPressGestureRecognizer.minimumPressDuration = 0.25
        messageBubble.addGestureRecognizer(longPressGestureRecognizer)
        messageBubble.isUserInteractionEnabled = true
    }
}

import UIKit
import AudioToolbox

protocol SenderMessageCellDelegate: AnyObject {
    func messageSelected(_ messageCell: SenderMessageCell, message: Message)
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
    
    
    func setData(_ message: Message) {
        senderMessage = message
        messageBodyLabel.text = message.data.textBody
        timestampLabel.text = message.timestamp
    }
    
    
    private func customizeViewElements() {
        let cornerRadius = messageBubble.frame.size.height / 2.30
        messageBubble.layer.cornerRadius = cornerRadius
        messageButton.layer.cornerRadius = cornerRadius
        messageButton.setTitle(K.Case.emptyString, for: .normal)
    }
    
    
    
    //MARK: - MESSAGE BUTTON
    
    
    
    @IBAction private func messageButtonPressed(_ sender: UIButton) {
        guard let safeSenderMessage = senderMessage else { return }
        
        setMessageColor(UIColor.brandDarkMint)
        
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) {
            [unowned self] timer in
            DispatchQueue.main.async {
                if sender.isTracking {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    
                    self.delegate?.messageSelected(self, message: safeSenderMessage)
                }
                
                self.setMessageColor(UIColor.brandMint)
            }
        }
    }

    
    private func setMessageColor(_ color: UIColor?) {
        messageBubble.backgroundColor = color
        messageTail.tintColor = color
    }
}

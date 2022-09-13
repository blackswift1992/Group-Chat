import UIKit
import FirebaseAuth
import AudioToolbox

protocol SenderMessageCellDelegate: AnyObject {
    func messageSelected(_ messageCell: SenderMessageCell, row: Int, id: String, body: String)
}



class SenderMessageCell: UITableViewCell {
    @IBOutlet private weak var messageBubble: UIView!
    @IBOutlet private weak var messageTail: UIImageView!
    @IBOutlet private weak var messageBodyLabel: UILabel!
    @IBOutlet private weak var timestampLabel: UILabel!
    @IBOutlet private weak var messageButton: UIButton!
    
    weak var delegate: SenderMessageCellDelegate?

    private var messageRow: Int?
    private var messageId: String?
    private var userId: String?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        customizeViewElements()
    }
    
    
    func setMessageCellData(row: Int, id: String, userId: String, body: String, timestamp: String) {
        messageRow = row
        messageId = id
        self.userId = userId
        messageBodyLabel.text = body
        timestampLabel.text = timestamp
    }
    
    
    private func customizeViewElements() {
        let cornerRadius = messageBubble.frame.size.height / 2.30
        messageBubble.layer.cornerRadius = cornerRadius
        messageButton.layer.cornerRadius = cornerRadius
        messageButton.setTitle(K.Case.emptyString, for: .normal)
    }
    
    
    
    //MARK: - MESSAGE BUTTON
    

    
    @IBAction private func messageButtonPressed(_ sender: UIButton) {
        if userId == Auth.auth().currentUser?.uid {
            DispatchQueue.main.async {
                self.setMessageColor(UIColor.brandDarkMint)
                
                Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { [weak self] timer in
                    if sender.isTracking {
                        self?.setMessageColor(UIColor.brandMint)
                        
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

                        if let safeSelf = self,
                           let safeMessageRow = safeSelf.messageRow,
                           let safeMessageId = safeSelf.messageId,
                           let safeMessageBody = safeSelf.messageBodyLabel.text {
                            safeSelf.delegate?.messageSelected(safeSelf, row: safeMessageRow, id: safeMessageId, body: safeMessageBody)
                        }
                    }
                    
                    self?.setMessageColor(UIColor.brandMint)
                    
                }
            }
        }
    }
    
    
    private func setMessageColor(_ color: UIColor?) {
        messageBubble.backgroundColor = color
        messageTail.tintColor = color
    }
}

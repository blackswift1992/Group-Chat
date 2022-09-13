import UIKit
import FirebaseAuth
import AudioToolbox

class UserInfoViewController: UIViewController {
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var dataContainerView: UIView!
    @IBOutlet private weak var logOutView: UIView!
    
    @IBOutlet private weak var avatar: UIImageView!
    @IBOutlet private weak var firstNameLabel: UILabel!
    @IBOutlet private weak var lastNameLabel: UILabel!
    
    @IBOutlet private weak var logOutButton: UIButton!
    @IBOutlet private weak var deleteAccountButton: UIButton!
    
    private var senderFirstName: String?
    private var senderLastName: String?
    private var senderAvatar: UIImage?
    
    var logOutButtonPressedCallBack: (() -> ())?
    var deleteAccountButtonPressedCallBack: (() -> ())?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViewElements()
    }
    
    
    func setUserData(senderFirstName: String, senderLastName: String, senderAvatar: UIImage) {
        self.senderFirstName = senderFirstName
        self.senderLastName = senderLastName
        self.senderAvatar = senderAvatar
    }
    
    
    private func customizeViewElements() {
        avatar.layer.cornerRadius = 50
        avatar.layer.borderWidth = 0.5
        
        logOutView.layer.cornerRadius = 17
        deleteAccountButton.layer.cornerRadius = 17
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = containerView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(blurEffectView)
        containerView.addSubview(dataContainerView)
        
        backgroundView.layer.cornerRadius = 29;
        backgroundView.layer.masksToBounds = true;
        
        
        if let safeSenderFirstName = senderFirstName,
           let safeSenderLastName = senderLastName,
           let safeSenderAvatar = senderAvatar {
            firstNameLabel.text = safeSenderFirstName
            lastNameLabel.text = safeSenderLastName
            avatar.image = safeSenderAvatar
        }
    }
    
    
    @IBAction private func logOutButtonPressed(_ sender: UIButton) {
        disableButtonsInteraction()
        logOutButtonPressedCallBack?()
        self.dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction private func deleteAccountButtonPressed(_ sender: UIButton) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        navigateToDeleteAccountWarning()
    }
    
    
    private func deleteAccountAndData() {
        view.isHidden = true
        disableButtonsInteraction()
        deleteAccountButtonPressedCallBack?()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func disableButtonsInteraction() {
        logOutButton.isUserInteractionEnabled = false
        deleteAccountButton.isUserInteractionEnabled = false
    }
    

    private func navigateToDeleteAccountWarning() {
        performSegue(withIdentifier: K.Segue.userInfoToDeleteAccountWarning, sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.userInfoToDeleteAccountWarning {
            if let destinationVC = segue.destination as? DeleteAccountWarningViewController {
                destinationVC.yesButtonPressedCallBack = { [weak self] in
                    self?.deleteAccountAndData()
                }
            }
        }
    }
    
    
    //any touch out of the UI element heads back to previous view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismiss(animated: true, completion: nil)
    }
}



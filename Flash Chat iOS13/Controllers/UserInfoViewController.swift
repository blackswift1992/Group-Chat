import UIKit
import FirebaseAuth
import AudioToolbox

class UserInfoViewController: UIViewController {
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var dataContainerView: UIView!
    @IBOutlet private weak var logOutView: UIView!
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var firstNameLabel: UILabel!
    @IBOutlet private weak var lastNameLabel: UILabel!
    
    @IBOutlet private weak var deleteAccountButton: UIButton!
 
    private var chatSender: ChatUser?
    private var logOutButtonPressedCallBack: (() -> ())?
    private var deleteAccountButtonPressedCallBack: (() -> ())?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViewElements()
    }

    
    func setChatSender(_ chatSender: ChatUser?) {
        self.chatSender = chatSender
    }
    
    
    func setLogOutButtonPressedCallBack(_ logOutCallback: (() -> ())?) {
        logOutButtonPressedCallBack = logOutCallback
    }
    
    
    func setDeleteAccountButtonPressedCallBack(_ deleteAccountCallback: (() -> ())?) {
        deleteAccountButtonPressedCallBack = deleteAccountCallback
    }
    
    
    private func customizeViewElements() {
        avatarImageView.layer.cornerRadius = 50
        avatarImageView.layer.borderWidth = 0.5
        
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
        
        firstNameLabel.text = chatSender?.data.firstName
        lastNameLabel.text = chatSender?.data.lastName
        avatarImageView.image = chatSender?.avatar
    }
    
    
    @IBAction private func logOutButtonPressed(_ sender: UIButton) {
        view.isHidden = true
        logOutButtonPressedCallBack?()
        self.dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction private func deleteAccountButtonPressed(_ sender: UIButton) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
//        navigateToDeleteAccountWarning()
        self.dismiss(animated: true, completion: nil)
        deleteAccountButtonPressedCallBack?()
        
    }
    
    
//    private func deleteAccount() {
//        view.isHidden = true
//        deleteAccountButtonPressedCallBack?()
//        self.dismiss(animated: true, completion: nil)
//    }
    

//    private func navigateToDeleteAccountWarning() {
//        performSegue(withIdentifier: K.Segue.userInfoToDeleteAccountWarning, sender: self)
//    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == K.Segue.userInfoToDeleteAccountWarning {
//            if let destinationVC = segue.destination as? DeleteAccountWarningViewController {
//                destinationVC.yesButtonPressedCallBack = { [weak self] in
//                    self?.deleteAccount()
//                }
//            }
//        }
//    }
    
    
    //any touch out of the UI element heads back to previous view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismiss(animated: true, completion: nil)
    }
}



import UIKit
import FirebaseAuth
import AudioToolbox

class UserMenuViewController: UIViewController {
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var dataContainerView: UIView!
    @IBOutlet private weak var logOutView: UIView!
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var firstNameLabel: UILabel!
    @IBOutlet private weak var lastNameLabel: UILabel!
    
    @IBOutlet private weak var deleteAccountButton: UIButton!
 
    private var chatSender: ChatUser?
    private var editAccountButtonPressedCallBack: (() -> ())?
    private var logOutButtonPressedCallBack: (() -> ())?
    private var deleteAccountButtonPressedCallBack: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViewElements()
    }
}


//MARK: - Public methods


extension UserMenuViewController {
    func setChatSender(_ chatSender: ChatUser?) {
        self.chatSender = chatSender
    }
    
    func setLogOutButtonPressedCallBack(_ logOutCallback: (() -> ())?) {
        logOutButtonPressedCallBack = logOutCallback
    }
    
    func setEditAccountButtonPressedCallBack(_ editAccountCallback: (() -> ())?) {
        editAccountButtonPressedCallBack = editAccountCallback
    }
    
    func setDeleteAccountButtonPressedCallBack(_ deleteAccountCallback: (() -> ())?) {
        deleteAccountButtonPressedCallBack = deleteAccountCallback
    }
}


//MARK: - @IBActions


extension UserMenuViewController {
    @IBAction private func editAccountButtonPressed(_ sender: UIButton) {
        dismiss(animated: false) {
            self.editAccountButtonPressedCallBack?()
        }
    }
    
    @IBAction private func logOutButtonPressed(_ sender: UIButton) {
        dismiss(animated: false) {
            self.logOutButtonPressedCallBack?()
        }
    }
    
    @IBAction private func deleteAccountButtonPressed(_ sender: UIButton) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        navigateToDeleteAccountWarning()
    }
}


//MARK: - Private methods


extension UserMenuViewController {
    private func deleteAccountTotally() {
        view.isHidden = true
        
        dismiss(animated: false) {
            self.deleteAccountButtonPressedCallBack?()
        }
    }
    
    private func navigateToDeleteAccountWarning() {
        performSegue(withIdentifier: K.Segue.userMenuToDeleteAccountWarning, sender: self)
    }
}


//MARK: - Set up methods


extension UserMenuViewController {
    private func customizeViewElements() {
        backgroundView.layer.cornerRadius = 29;
        backgroundView.layer.masksToBounds = true;
        
        avatarImageView.layer.cornerRadius = 50
        avatarImageView.layer.borderWidth = 0.5
        
        logOutView.layer.cornerRadius = 17
        deleteAccountButton.layer.cornerRadius = 17
        
        activateBlurEffectInContainerView()
        
        if let safeChatSender = chatSender {
            firstNameLabel.text = safeChatSender.data.firstName
            lastNameLabel.text = safeChatSender.data.lastName
            avatarImageView.image = safeChatSender.avatar
        }
    }
    
    private func activateBlurEffectInContainerView() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = containerView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(blurEffectView)
        containerView.addSubview(dataContainerView)
    }
    
    //any touch out of the UI element heads back to previous view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.userMenuToDeleteAccountWarning {
            if let destinationVC = segue.destination as? DeleteAccountWarningViewController {
                destinationVC.setYesButtonPressedCallBack({ [weak self] in
                    self?.deleteAccountTotally()
                })
            }
        }
    }
}


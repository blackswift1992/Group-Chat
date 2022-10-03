import UIKit
import AudioToolbox

class DeleteAccountWarningViewController: UIViewController {
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var containerView: UIStackView!
    
    private var yesButtonPressedCallBack: (() -> ())?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViewElements()
    }
    
    
    func setYesButtonPressedCallBack(_ yesCallback: (() -> ())?) {
        yesButtonPressedCallBack = yesCallback
    }
    
    
    private func customizeViewElements() {
        containerView.layer.cornerRadius = 17;
        containerView.layer.masksToBounds = true;
        
        activateBlurEffectInBackgroundView()
    }
    
    
    private func activateBlurEffectInBackgroundView() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.addSubview(blurEffectView)
        backgroundView.addSubview(containerView)
    }
    
    
    @IBAction private func yesButtonPressed(_ sender: UIButton) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        dismiss(animated: true) {
            self.yesButtonPressedCallBack?()
        }
    }
    
    
    @IBAction private func noButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
//    any touch out of the UI element heads back to previous view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismiss(animated: true, completion: nil)
    }
}


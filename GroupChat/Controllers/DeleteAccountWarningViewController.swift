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
}


//MARK: - Public methods


extension DeleteAccountWarningViewController {
    func setYesButtonPressedCallBack(_ yesCallback: (() -> ())?) {
        yesButtonPressedCallBack = yesCallback
    }
}


//MARK: - @IBActions


private extension DeleteAccountWarningViewController {
    @IBAction func yesButtonPressed(_ sender: UIButton) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        dismiss(animated: true) {
            self.yesButtonPressedCallBack?()
        }
    }
    
    @IBAction func noButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - Private methods


private extension DeleteAccountWarningViewController {
    @objc func respondToGesture() {
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - Set up methods


private extension DeleteAccountWarningViewController {
    func customizeViewElements() {
        containerView.layer.cornerRadius = 17;
        containerView.layer.masksToBounds = true;
        activateBlurEffectInBackgroundView()
        setGestureRecognizerToView()
    }
    
    func activateBlurEffectInBackgroundView() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.addSubview(blurEffectView)
        backgroundView.addSubview(containerView)
    }
    
    func setGestureRecognizerToView() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(respondToGesture))
        view.addGestureRecognizer(gestureRecognizer)
        view.isUserInteractionEnabled = true
    }
}


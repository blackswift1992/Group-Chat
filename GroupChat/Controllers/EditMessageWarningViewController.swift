import UIKit

class EditMessageWarningViewController: UIViewController {
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var containerView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViewElements()
    }
}


//MARK: - @IBActions


private extension EditMessageWarningViewController {
    @IBAction func okButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: - Private methods


private extension EditMessageWarningViewController {
    @objc func respondToGesture() {
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - Set up methods


private extension EditMessageWarningViewController {
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


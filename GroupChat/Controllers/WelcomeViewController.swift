import UIKit
import CLTypingLabel

class WelcomeViewController: UIViewController {
    @IBOutlet private weak var titleLabel: CLTypingLabel!
    @IBOutlet private weak var logInButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViewElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
}


//MARK: - Set up methods


private extension WelcomeViewController {
    func customizeViewElements() {
        titleLabel.text = K.appName
        logInButton.layer.cornerRadius = 23
        registerButton.layer.cornerRadius = 13
    }
}

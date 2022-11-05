import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    @IBOutlet private weak var errorLabel: UILabel!

    @IBOutlet private weak var emailTextfield: UITextField!
    @IBOutlet private weak var passwordTextfield: UITextField!
    
    @IBOutlet private weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var signUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViewElements()
    }
}


//MARK: - @IBActions


private extension SignUpViewController {
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        guard let safeUserEmail = emailTextfield.text,
              let safeUserPassword = passwordTextfield.text
        else { return }
        
        activateScreenWaitingMode()
        
        Auth.auth().createUser(withEmail: safeUserEmail, password: safeUserPassword) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let safeError = error {
                    print(safeError)
                    self?.failedToSignUp(withMessage: safeError.localizedDescription)
                } else {
                    self?.navigateToNewUserData()
                }
            }
        }
    }
}


//MARK: - Private methods


private extension SignUpViewController {
    func activateScreenWaitingMode() {
        errorLabel.text = K.Case.emptyString
        view.isUserInteractionEnabled = false
        progressIndicator.startAnimating()
    }
    
    func failedToSignUp(withMessage message: String) {
        errorLabel.text = message
        view.isUserInteractionEnabled = true
        progressIndicator.stopAnimating()
    }
    
    func navigateToNewUserData() {
        performSegue(withIdentifier: K.Segue.signUpToNewUserData, sender: self)
    }
}


//MARK: - Set up methods


private extension SignUpViewController {
    func customizeViewElements() {
        progressIndicator.hidesWhenStopped = true
    }
}

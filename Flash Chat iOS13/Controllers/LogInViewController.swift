import UIKit
import FirebaseAuth
import FirebaseFirestore

class LogInViewController: UIViewController {
    @IBOutlet private weak var errorLabel: UILabel!
    
    @IBOutlet private weak var emailTextfield: UITextField!
    @IBOutlet private weak var passwordTextfield: UITextField!
    
    @IBOutlet private weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var logInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViewElements()
    }
    
    
    private func customizeViewElements() {
        progressIndicator.hidesWhenStopped = true
    }
    

    private func failedToLogIn(withMessage message: String) {
        errorLabel.text = message
        view.isUserInteractionEnabled = true
        progressIndicator.stopAnimating()
    }
    
    
    private func activateScreenWaitingMode() {
        errorLabel.text = K.Case.emptyString
        view.isUserInteractionEnabled = false
        progressIndicator.startAnimating()
    }

    
    
    //MARK: - LOG IN BUTTON
    
    
    
    @IBAction private func logInButtonPressed(_ sender: UIButton) {
        guard let safeUserEmail = emailTextfield.text,
              let safeUserPassword = passwordTextfield.text else { return }
        
        activateScreenWaitingMode()
        
        Auth.auth().signIn(withEmail: safeUserEmail, password: safeUserPassword) {
            [weak self] authResult, error in
            DispatchQueue.main.async {
                if let safeError = error {
                    print(safeError)
                    self?.failedToLogIn(withMessage: safeError.localizedDescription)
                } else {
                    self?.checkIsUserDataExists()
                }
            }
        }
    }
    
    
    private func checkIsUserDataExists() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.failedToLogIn(withMessage: "Try again")
            return
        }
        
        Firestore.firestore().collection(K.FStore.usersCollection).document(userId).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                self?.navigateToChat()
            } else {
                self?.navigateToNewUserData()
            }
        }
    }
    
    
    private func navigateToChat() {
        performSegue(withIdentifier: K.Segue.logInToChat, sender: self)
    }
    
    
    private func navigateToNewUserData() {
        performSegue(withIdentifier: K.Segue.logInToNewUserData, sender: self)
    }
}

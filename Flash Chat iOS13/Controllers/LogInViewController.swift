import UIKit
import FirebaseAuth

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
        progressIndicator.stopAnimating()
    }
    
    
    private func setViewElementsInteraction(_ state: Bool) {
        emailTextfield.isUserInteractionEnabled = state
        passwordTextfield.isUserInteractionEnabled = state
        logInButton.isUserInteractionEnabled = state
    }
    

    private func failedToLogIn(with error: Error) {
        errorLabel.text = error.localizedDescription
    }

    
    
    //MARK: - LOG IN BUTTON
    
    
    
    @IBAction private func logInButtonPressed(_ sender: UIButton) {
        guard let safeUserEmail = emailTextfield.text,
              let safeUserPassword = passwordTextfield.text else { return }
        
        setViewElementsInteraction(false)
        progressIndicator.startAnimating()
        
        Auth.auth().signIn(withEmail: safeUserEmail, password: safeUserPassword) {
            [weak self] authResult, error in
            if let safeError = error {
                print(safeError)
                
                DispatchQueue.main.async {
                    self?.failedToLogIn(with: safeError)
                    self?.setViewElementsInteraction(true)
                    self?.progressIndicator.stopAnimating()
                }
            } else {
                self?.navigateToChat()
            }
        }
    }
    
    
    private func navigateToChat() {
        performSegue(withIdentifier: K.Segue.logInToChat, sender: self)
    }
}

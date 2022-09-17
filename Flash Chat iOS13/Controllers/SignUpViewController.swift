import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    @IBOutlet private weak var errorLabel: UILabel!

    @IBOutlet private weak var emailTextfield: UITextField!
    @IBOutlet private weak var passwordTextfield: UITextField!
    
    @IBOutlet private weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var signUpButton: UIButton!
    
    var userRGBColor: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeViewElements()
        generateUserRGBColorString()
    }
    
    
    private func customizeViewElements() {
        progressIndicator.hidesWhenStopped = true
        progressIndicator.stopAnimating()
    }
    
    
    private func setViewElementsInteraction(_ state: Bool) {
        emailTextfield.isUserInteractionEnabled = state
        passwordTextfield.isUserInteractionEnabled = state
        signUpButton.isUserInteractionEnabled = state
    }
    
    
    private func failedToSignUp(with error: Error) {
        errorLabel.text = error.localizedDescription
    }
    
    
    
    //MARK: - SIGN UP BUTTON
    
    
    
    @IBAction private func signUpButtonPressed(_ sender: UIButton) {
        guard let safeUserEmail = emailTextfield.text,
              let safeUserPassword = passwordTextfield.text else { return }
        
        setViewElementsInteraction(false)
        progressIndicator.startAnimating()
        
        Auth.auth().createUser(withEmail: safeUserEmail, password: safeUserPassword) {
            [weak self] authResult, error in
            if let safeError = error {
                print(safeError)
                
                DispatchQueue.main.async {
                    self?.failedToSignUp(with: safeError)
                    self?.setViewElementsInteraction(true)
                    self?.progressIndicator.stopAnimating()

                }
            } else {
                self?.uploadDefaultUserData()
            }
        }
    }
    
    
    private func uploadDefaultUserData() {
        guard let safeUserId = Auth.auth().currentUser?.uid,
              let safeUserEmail = emailTextfield.text,
              let safeUserRGBColor = userRGBColor
        else { return }
        
        let docData: [String: Any] = [
            K.FStore.userIdField: safeUserId,
            K.FStore.userEmailField: safeUserEmail,
            K.FStore.firstNameField: K.Case.unknown,
            K.FStore.lastNameField: K.Case.unknown,
            K.FStore.userRGBColorField: safeUserRGBColor,
            K.FStore.avatarURLField: K.Case.no
        ]
        
        Firestore.firestore().collection(K.FStore.usersCollection).document(safeUserId).setData(docData) { [weak self] error in
            if let safeError = error {
                print("Error uploading DefaultUserData: \(safeError)")
            } else {
                self?.navigateToNewUserData()
            }
        }
    }
    
    
    private func generateUserRGBColorString() {
        signUpButton.isUserInteractionEnabled = false
        
        let red = round(Double.random(in: 0.4...1.0) * 100) / 100.0
        let green = round(Double.random(in: 0.4...1.0) * 100) / 100.0
        let blue = round(Double.random(in: 0.4...1.0) * 100) / 100.0
        
        userRGBColor = "\(red),\(green),\(blue)"
        
        signUpButton.isUserInteractionEnabled = true
    }
    
    
    
    
    private func navigateToNewUserData() {
        performSegue(withIdentifier: K.Segue.signUpToNewUserData, sender: self)
    }
}



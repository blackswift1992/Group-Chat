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
    
    
    private func customizeViewElements() {
        progressIndicator.hidesWhenStopped = true
        progressIndicator.stopAnimating()
    }
    
    
    //замінить рядки на commonView і після цього видалити аутлети які не юзаються
    private func setViewElementsInteraction(_ state: Bool) {
        emailTextfield.isUserInteractionEnabled = state
        passwordTextfield.isUserInteractionEnabled = state
        signUpButton.isUserInteractionEnabled = state
    }
    
    
    private func failedToSignUp(with errorDescription: String) {
        errorLabel.text = errorDescription
        setViewElementsInteraction(true)
        progressIndicator.stopAnimating()
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
                    self?.failedToSignUp(with: safeError.localizedDescription)
                }
            } else {
                guard let safeAuthResult = authResult else { return }
                
                self?.uploadDefaultUserData(userId: safeAuthResult.user.uid, userEmail: safeUserEmail)
            }
        }
    }
    
    
    private func uploadDefaultUserData(userId: String, userEmail: String) {
        let docData: [String: Any] = [
            K.FStore.userIdField: userId,
            K.FStore.userEmailField: userEmail,
            K.FStore.firstNameField: K.Case.unknown,
            K.FStore.lastNameField: K.Case.unknown,
            K.FStore.userRGBColorField: UIColor.generateUserRGBColorString(),
            K.FStore.avatarURLField: K.Case.no
        ]
        
        Firestore.firestore().collection(K.FStore.usersCollection).document(userId).setData(docData) { [weak self] error in
            if let safeError = error {
                print("Error uploading DefaultUserData: \(safeError)")
                
                //In NewUserDataViewController there is a code that duplicate default user data uploading (insurance).
                self?.navigateToNewUserData()
            } else {
                self?.navigateToNewUserData()
            }
        }
    }
    
    
    
    private func navigateToNewUserData() {
        performSegue(withIdentifier: K.Segue.signUpToNewUserData, sender: self)
    }
}



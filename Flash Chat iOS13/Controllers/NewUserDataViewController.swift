import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class NewUserDataViewController: UIViewController {
    @IBOutlet private weak var errorLabel: UILabel!
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var loadPhotoButton: UIButton!
    
    @IBOutlet private weak var firstNameTextField: UITextField!
    @IBOutlet private weak var lastNameTextField: UITextField!
    
    @IBOutlet private weak var progressIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var continueButton: UIButton!
    
    
    
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
    
    
    private func customizeViewElements() {
        avatarImageView.layer.cornerRadius = 50
        avatarImageView.layer.borderWidth = 0.5
        
        loadPhotoButton.layer.cornerRadius = 16
        
        progressIndicator.hidesWhenStopped = true
    }
    
    //замінить рядки на commonView і після цього видалити аутлети які не юзаються
    private func setViewElementsInteraction(_ state: Bool) {
        firstNameTextField.isUserInteractionEnabled = state
        lastNameTextField.isUserInteractionEnabled = state
        continueButton.isUserInteractionEnabled = state
        loadPhotoButton.isUserInteractionEnabled = state
    }
    
    
    private func navigateToChat() {
        performSegue(withIdentifier: K.Segue.newUserDataToChat, sender: self)
    }
    
    
    private func failedWithErrorMessage(_ errorDescription: String) {
        errorLabel.text = errorDescription
        progressIndicator.stopAnimating()
        setViewElementsInteraction(true)
    }
    
    private func activateScreenWaitingMode() {
        errorLabel.text = ""
        progressIndicator.startAnimating()
        setViewElementsInteraction(false)
    }
    
    
    //MARK: - CONTINUE BUTTON
    
    
    
    @IBAction private func continueButtonPressed(_ sender: UIButton) {
        guard let safeUserId = Auth.auth().currentUser?.uid,
              let safeUserEmail = Auth.auth().currentUser?.email,
              let safeFirstName = firstNameTextField.text,
              var safeLastName = lastNameTextField.text,
              let safeAvatarData = avatarImageView.image?.jpegData(compressionQuality: 0.02)
        else { return }
        
        activateScreenWaitingMode()
        
        if !safeFirstName.isEmpty {
            uploadUserAvatarAndData(userId: safeUserId, userEmail: safeUserEmail, firstName: safeFirstName, lastName: safeLastName, userAvatarData: safeAvatarData)
        } else {
            failedWithErrorMessage("Type your first name")
        }
    }
    
    
    private func uploadUserAvatarAndData(userId: String, userEmail: String, firstName: String, lastName: String, userAvatarData: Data) {
        
        let avatarMetaData = StorageMetadata()
        avatarMetaData.contentType = K.Image.jpegType
        
        let avatarRef = Storage.storage().reference()
            .child(K.FStore.avatarsCollection)
            .child(userId)
        
        avatarRef.putData(userAvatarData, metadata: avatarMetaData) { [weak self] metaData, error in
            guard let _ = metaData else {
                self?.failedWithErrorMessage("Try again")
                return
            }
            
            avatarRef.downloadURL { [weak self] url, error in
                guard let safeURL = url else {
                    self?.failedWithErrorMessage("Try again")
                    return
                }
                
                self?.uploadUserData(userId: userId, userEmail: userEmail, firstName: firstName, lastName: lastName, uploadedAvatarURL: safeURL.absoluteString)
            }
        }
    }
    
    
    private func uploadUserData(userId: String, userEmail: String, firstName: String, lastName: String, uploadedAvatarURL: String) {
        let docData: [String: Any] = [
            K.FStore.userIdField: userId,
            K.FStore.userEmailField: userEmail,
            K.FStore.firstNameField: firstName,
            K.FStore.lastNameField: lastName,
            K.FStore.userRGBColorField: UIColor.getRandomRGBString(),
            K.FStore.avatarURLField: uploadedAvatarURL
        ]
        
        Firestore.firestore().collection(K.FStore.usersCollection).document(userId).setData(docData) { [weak self] error in
            if let _ = error {
                self?.failedWithErrorMessage("Try again")
            } else {
                self?.navigateToChat()
            }
        }
    }
}

//MARK: - LOAD PHOTO BUTTON



extension NewUserDataViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBAction private func loadPhotoButtonPressed(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        avatarImageView.image = image
    }
}



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
    @IBOutlet private weak var skipButton: UIButton!
    

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
        avatarImageView.image = UIImage(named: K.Image.defaultAvatar)
        avatarImageView.layer.cornerRadius = 50
        avatarImageView.layer.borderWidth = 0.5
        
        loadPhotoButton.layer.cornerRadius = 16
        skipButton.layer.cornerRadius = 9
        
        progressIndicator.hidesWhenStopped = true
        progressIndicator.stopAnimating()
    }

    //замінить рядки на commonView і після цього видалити аутлети які не юзаються
    private func setViewElementsInteraction(_ state: Bool) {
        firstNameTextField.isUserInteractionEnabled = state
        lastNameTextField.isUserInteractionEnabled = state
        continueButton.isUserInteractionEnabled = state
        skipButton.isUserInteractionEnabled = state
        loadPhotoButton.isUserInteractionEnabled = state
    }
    
//    Додати методи типу failedToSignUp
    
    
    private func navigateToChat() {
        performSegue(withIdentifier: K.Segue.newUserDataToChat, sender: self)
    }
    
    
    
    
    //MARK: - CONTINUE BUTTON
    
    
    
    @IBAction private func continueButtonPressed(_ sender: UIButton) {
        guard let safeUserId = Auth.auth().currentUser?.uid,
              let safeUserEmail = Auth.auth().currentUser?.email,
              let safeFirstName = firstNameTextField.text,
              let safeLastName = lastNameTextField.text,
              let safeUserAvatar = avatarImageView.image,
              let safeAvatarData = safeUserAvatar.jpegData(compressionQuality: 0.02)
        else { return }
        
        progressIndicator.startAnimating()
        setViewElementsInteraction(false)
        
        
        if !safeFirstName.isEmpty && !safeLastName.isEmpty {
            //Заминінити UIImage(named: K.Image.defaultAvatar) на UIImage.defaultAvatar
            if safeUserAvatar != UIImage(named: K.Image.defaultAvatar) {
                uploadUserDataAndAvatar(userId: safeUserId, userEmail: safeUserEmail, firstName: safeFirstName, lastName: safeLastName, userAvatarData: safeAvatarData)
            } else {
                uploadUserData(userId: safeUserId, userEmail: safeUserEmail, firstName: safeFirstName, lastName: safeLastName, uploadedAvatarURL: nil)
            }
        } else {
            errorLabel.text = "Type your first name and last name"
            
            progressIndicator.stopAnimating()
            setViewElementsInteraction(true)
        }
    }
    
    
    private func uploadUserDataAndAvatar(userId: String, userEmail: String, firstName: String, lastName: String, userAvatarData: Data) {
        
        let avatarMetaData = StorageMetadata()
        avatarMetaData.contentType = K.Image.jpegType
        
        let avatarRef = Storage.storage().reference()
            .child(K.FStore.avatarsCollection)
            .child(userId)
        
        avatarRef.putData(userAvatarData, metadata: avatarMetaData) { [weak self] metaData, error in
            guard let _ = metaData else {
                print("Uploading avatar data was failed")
                
                self?.progressIndicator.stopAnimating()
                self?.setViewElementsInteraction(true)
                
                return
            }
            
            avatarRef.downloadURL { [weak self] url, error in
                guard let safeURL = url else {
                    print("Downloading avatarURL was failed")
                    
                    self?.progressIndicator.stopAnimating()
                    self?.setViewElementsInteraction(true)
                    
                    return
                }
                
                self?.uploadUserData(userId: userId, userEmail: userEmail, firstName: firstName, lastName: lastName, uploadedAvatarURL: safeURL.absoluteString)
            }
            
        }
    }
    
    
    private func uploadUserData(userId: String, userEmail: String, firstName: String?, lastName: String?, uploadedAvatarURL: String?) {
        var docData: [String: Any] = [
            K.FStore.userIdField: userId,
            K.FStore.userEmailField: userEmail,
            K.FStore.firstNameField: K.Case.unknown,
            K.FStore.lastNameField: K.Case.unknown,
            K.FStore.userRGBColorField: UIColor.generateUserRGBColorString(),
            K.FStore.avatarURLField: K.Case.no
        ]
        
        if let safeFirstName = firstName {
            docData[K.FStore.firstNameField] = safeFirstName
        }
        
        if let safeLastName = lastName {
            docData[K.FStore.lastNameField] = safeLastName
        }
        
        if let safeAvatarURL = uploadedAvatarURL {
            docData[K.FStore.avatarURLField] = safeAvatarURL
        }
        
        Firestore.firestore().collection(K.FStore.usersCollection).document(userId).setData(docData) { [weak self] error in
            if let safeError = error {
                print("Error writing document: \(safeError)")
                
                self?.errorLabel.text = "Try again!"
                self?.progressIndicator.stopAnimating()
                self?.setViewElementsInteraction(true)
                
            } else {
                self?.navigateToChat()
            }
        }
    }
    
    
    
    //MARK: - SKIP BUTTON
    
    
    
    @IBAction private func skipButtonPressed(_ sender: UIButton) {
        guard let safeUserId = Auth.auth().currentUser?.uid,
              let safeUserEmail = Auth.auth().currentUser?.email
        else { return }
        
        progressIndicator.startAnimating()
        setViewElementsInteraction(false)
        
        uploadUserData(userId: safeUserId, userEmail: safeUserEmail, firstName: nil, lastName: nil, uploadedAvatarURL: nil)
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



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

    
    private func setViewElementsInteraction(_ state: Bool) {
        firstNameTextField.isUserInteractionEnabled = state
        lastNameTextField.isUserInteractionEnabled = state
        continueButton.isUserInteractionEnabled = state
        skipButton.isUserInteractionEnabled = state
        loadPhotoButton.isUserInteractionEnabled = state
    }
    
    
    private func navigateToChat() {
        performSegue(withIdentifier: K.Segue.newUserDataToChat, sender: self)
    }
    
    
    
    //MARK: - CONTINUE BUTTON
    
    
    
    @IBAction private func continueButtonPressed(_ sender: UIButton) {
        progressIndicator.startAnimating()
        setViewElementsInteraction(false)
        
        guard let safeFirstName = firstNameTextField.text,
              let safeLastName = lastNameTextField.text
        else { return }
        
        if safeFirstName != K.Case.emptyString && safeLastName != K.Case.emptyString {
            if avatarImageView.image == UIImage(named: K.Image.defaultAvatar) {
                uploadUserData(uploadedAvatarURL: nil)
            } else {
                uploadUserAvatarAndData()
            }
        } else {
            errorLabel.text = "Type your first name and last name"
            
            progressIndicator.stopAnimating()
            setViewElementsInteraction(true)
        }
    }
    
    
    private func uploadUserAvatarAndData() {
        guard let safeUserId = Auth.auth().currentUser?.uid,
              let safeAvatar = avatarImageView.image
        else { return }
        
        let avatarRef = Storage.storage().reference()
            .child(K.FStore.avatarsCollection)
            .child(safeUserId)
        
        guard let avatarData = safeAvatar.jpegData(compressionQuality: 0.02) else { return }
        
        let avatarMetaData = StorageMetadata()
        avatarMetaData.contentType = K.Image.jpegType
        
        avatarRef.putData(avatarData, metadata: avatarMetaData) { metaData, error in
            guard let _ = metaData else {
                print("Uploading avatar data was failed")
                return
            }
            
            avatarRef.downloadURL { [weak self] url, error in
                guard let safeURL = url else {
                    print("Downloading avatarURL was failed")
                    return
                }
                
                self?.uploadUserData(uploadedAvatarURL: safeURL.absoluteString)
            }
            
        }
    }
    
    
    private func uploadUserData(uploadedAvatarURL: String?) {
        guard let safeUserId = Auth.auth().currentUser?.uid,
              let safeFirstName = firstNameTextField.text,
              let safeLastName = lastNameTextField.text
        else { return }
        
        var docData: [String: Any] = [
            K.FStore.firstNameField: safeFirstName,
            K.FStore.lastNameField: safeLastName
        ]
        
        if let safeAvatarURL = uploadedAvatarURL {
            docData[K.FStore.avatarURLField] = safeAvatarURL
        }
        
        Firestore.firestore().collection(K.FStore.usersCollection).document(safeUserId).setData(docData, merge: true) { [weak self] error in
            if let safeError = error {
                print("Error writing document: \(safeError)")
            } else {
                self?.navigateToChat()
            }
        }
    }
    
    
    
    //MARK: - SKIP BUTTON
    
    
    
    @IBAction private func skipButtonPressed(_ sender: UIButton) {
        navigateToChat()
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



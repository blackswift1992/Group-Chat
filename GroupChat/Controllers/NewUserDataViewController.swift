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
    
    private var chatSender: ChatUser?
    private var errorMessage: String?
    
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
    
    //MARK: -- preparing for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.newUserDataToChat {
            if let destinationVC = segue.destination as? ChatViewController {
                destinationVC.setChatSender(chatSender)
            }
        }
    }
}


//MARK: - Public methods


extension NewUserDataViewController {
    func setChatSender(_ chatSender: ChatUser?, errorMessage: String?) {
        self.chatSender = chatSender
        self.errorMessage = errorMessage
    }
}


//MARK: - Protocols


extension NewUserDataViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        avatarImageView.image = image
    }
}


//MARK: - @IBActions


private extension NewUserDataViewController {
    @IBAction func loadPhotoButtonPressed(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        guard let safeFirstName = firstNameTextField.text?.trim() else { return }
        
        activateScreenWaitingMode()

        if !safeFirstName.isEmpty {
            uploadAvatar()
        } else {
            failedWithErrorMessage("Type your first name")
        }
    }
}


//MARK: - Private methods


private extension NewUserDataViewController {
    //MARK: -- avatar uploading
    func uploadAvatar() {
        guard let safeUserId = Auth.auth().currentUser?.uid,
              let safeUserEmail = Auth.auth().currentUser?.email,
              let safeFirstName = firstNameTextField.text?.trim(),
              let safeLastName = lastNameTextField.text?.trim(),
              let safeAvatarData = avatarImageView.image?.jpegData(compressionQuality: 0.02),
              let safeCompressedAvatar = UIImage(data: safeAvatarData)
        else {
            failedWithErrorMessage("Try again")
            return
        }
        
        let avatarMetaData = StorageMetadata()
        avatarMetaData.contentType = K.Image.jpegType
        
        let avatarRef = Storage.storage().reference()
            .child(K.FStore.avatarsCollection)
            .child(safeUserId)
        
        avatarRef.putData(safeAvatarData, metadata: avatarMetaData) {
            [weak self] metaData, error in
            if metaData == nil {
                DispatchQueue.main.async {
                    self?.failedWithErrorMessage("Try again")
                }
                return
            }
            
            avatarRef.downloadURL { [weak self] url, error in
                guard let safeURL = url else {
                    DispatchQueue.main.async {
                        self?.failedWithErrorMessage("Try again")
                    }
                    return
                }
                
                let userRGBColor = self?.chatSender?.data.userRGBColor ?? UIColor.getRandomRGBString()
                
                let chatUserData = ChatUserData(userId: safeUserId, userEmail: safeUserEmail, firstName: safeFirstName, lastName: safeLastName, avatarURL: safeURL.absoluteString, userRGBColor: userRGBColor)
                
                self?.chatSender = ChatUser(data: chatUserData, avatar: safeCompressedAvatar)
                
                self?.uploadData(chatUserData)
            }
        }
    }
    
    //MARK: -- data uploading
    func uploadData(_ chatUserData: ChatUserData) {
        do {
            try Firestore.firestore().collection(K.FStore.usersCollection).document(chatUserData.userId).setData(from: chatUserData) { [weak self] error in
                DispatchQueue.main.async {
                    if error != nil {
                        self?.failedWithErrorMessage("Try again")
                    } else {
                        self?.navigateToChat()
                    }
                }
            }
        } catch let error {
            print("Error writing city to Firestore: \(error)")
            
            DispatchQueue.main.async {
                self.failedWithErrorMessage("Try again")
            }
        }
    }
    
    //MARK: -- others
    func activateScreenWaitingMode() {
        errorLabel.text = K.Case.emptyString
        view.isUserInteractionEnabled = false
        progressIndicator.startAnimating()
    }
    
    func failedWithErrorMessage(_ message: String) {
        errorLabel.text = message
        view.isUserInteractionEnabled = true
        progressIndicator.stopAnimating()
    }
    
    func navigateToChat() {
        performSegue(withIdentifier: K.Segue.newUserDataToChat, sender: self)
    }
}


//MARK: - Set up methods


private extension NewUserDataViewController {
    func customizeViewElements() {
        avatarImageView.layer.cornerRadius = 50
        avatarImageView.layer.borderWidth = 0.5
        
        loadPhotoButton.layer.cornerRadius = 16
        
        progressIndicator.hidesWhenStopped = true
        
        if let safeChatSender = chatSender {
            firstNameTextField.text = safeChatSender.data.firstName
            lastNameTextField.text = safeChatSender.data.lastName
            avatarImageView.image = safeChatSender.avatar
        }
        
        errorLabel.text = errorMessage
    }
}

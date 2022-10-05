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


extension NewUserDataViewController {
    @IBAction private func loadPhotoButtonPressed(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction private func continueButtonPressed(_ sender: UIButton) {
        activateScreenWaitingMode()

        guard let safeFirstName = firstNameTextField.text?.trim() else { return }

        if !safeFirstName.isEmpty {
            uploadAvatar()
        } else {
            failedWithErrorMessage("Type your first name")
        }
    }
}


//MARK: - Private methods


extension NewUserDataViewController {
    private func uploadAvatar() {
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
            DispatchQueue.main.async {
                guard let _ = metaData else {
                    self?.failedWithErrorMessage("Try again")
                    return
                }
                
                avatarRef.downloadURL { [weak self] url, error in
                    guard let safeURL = url else {
                        self?.failedWithErrorMessage("Try again")
                        return
                    }
                    
                    let userRGBColor = self?.chatSender?.data.userRGBColor ?? UIColor.getRandomRGBString()
                    
                    let chatUserData = ChatUserData(userId: safeUserId, userEmail: safeUserEmail, firstName: safeFirstName, lastName: safeLastName, avatarURL: safeURL.absoluteString, userRGBColor: userRGBColor)
                    
                    self?.chatSender = ChatUser(data: chatUserData, avatar: safeCompressedAvatar)
                    
                    self?.uploadData(chatUserData)
                }
            }
        }
    }
    
    private func uploadData(_ chatUserData: ChatUserData) {
        do {
            try Firestore.firestore().collection(K.FStore.usersCollection).document(chatUserData.userId).setData(from: chatUserData) { [weak self] error in
                if let _ = error {
                    self?.failedWithErrorMessage("Try again")
                } else {
                    self?.navigateToChat()
                }
            }
        } catch let error {
            print("Error writing city to Firestore: \(error)")
            failedWithErrorMessage("Try again")
        }
    }
    
    private func activateScreenWaitingMode() {
        errorLabel.text = K.Case.emptyString
        view.isUserInteractionEnabled = false
        progressIndicator.startAnimating()
    }
    
    private func failedWithErrorMessage(_ message: String) {
        errorLabel.text = message
        view.isUserInteractionEnabled = true
        progressIndicator.stopAnimating()
    }
    
    private func navigateToChat() {
        performSegue(withIdentifier: K.Segue.newUserDataToChat, sender: self)
    }
}


//MARK: - Set up methods


extension NewUserDataViewController {
    private func customizeViewElements() {
        avatarImageView.layer.cornerRadius = 50
        avatarImageView.layer.borderWidth = 0.5
        
        loadPhotoButton.layer.cornerRadius = 16
        
        progressIndicator.hidesWhenStopped = true
        
        if let safeChatSender = chatSender {
            firstNameTextField.text = safeChatSender.data.firstName
            lastNameTextField.text = safeChatSender.data.lastName
            avatarImageView.image = safeChatSender.avatar
            chatSender = nil
        }
        
        errorLabel.text = errorMessage
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.newUserDataToChat {
            if let destinationVC = segue.destination as? ChatViewController {
                destinationVC.setChatSender(chatSender)
            }
        }
    }
}

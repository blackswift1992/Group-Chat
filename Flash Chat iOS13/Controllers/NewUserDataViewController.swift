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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViewElements()
    }
    
    func setChatSender(_ user: ChatUser) {
        chatSender = user
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
        
        firstNameTextField.text = chatSender?.data.firstName
        lastNameTextField.text = chatSender?.data.lastName
        avatarImageView.image = chatSender?.avatar
        chatSender = nil
    }
    
 
    private func navigateToChat() {
        performSegue(withIdentifier: K.Segue.newUserDataToChat, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.newUserDataToChat {
            if let destinationVC = segue.destination as? ChatViewController {
                destinationVC.setChatSender(chatSender)
            }
        }
    }
    
    
    private func failedWithErrorMessage(_ message: String) {
        errorLabel.text = message
        view.isUserInteractionEnabled = true
        progressIndicator.stopAnimating()
    }
    
    private func activateScreenWaitingMode() {
        errorLabel.text = K.Case.emptyString
        view.isUserInteractionEnabled = false
        progressIndicator.startAnimating()
    }
    
    
    //MARK: - CONTINUE BUTTON
    
    
    
    @IBAction private func continueButtonPressed(_ sender: UIButton) {
        activateScreenWaitingMode()

        guard let safeFirstName = firstNameTextField.text else { return }
        
        if !safeFirstName.isEmpty {
            uploadAvatar()
        } else {
            failedWithErrorMessage("Type your first name")
        }
    }
    
    
    private func uploadAvatar() {
        guard let safeUserId = Auth.auth().currentUser?.uid,
              let safeUserEmail = Auth.auth().currentUser?.email,
              let safeFirstName = firstNameTextField.text,
              let safeLastName = lastNameTextField.text,
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
                    
                    let chatUserData = ChatUserData(userId: safeUserId, userEmail: safeUserEmail, firstName: safeFirstName, lastName: safeLastName, avatarURL: safeURL.absoluteString, userRGBColor: UIColor.getRandomRGBString())
                    
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



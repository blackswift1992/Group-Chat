import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import IQKeyboardManagerSwift

class ChatViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    //замінити edit на editing
    @IBOutlet private weak var editBlockView: UIView!
    @IBOutlet private weak var editBlockMessageTextLabel: UILabel!
    @IBOutlet private weak var editBlockCancelButton: UIButton!
    
    @IBOutlet private weak var messageTextField: UITextField!
    @IBOutlet private weak var sendButton: UIButton!
    
    @IBOutlet private weak var deletingView: UIView!
    @IBOutlet private weak var deletingLabel: UILabel!
    
    @IBOutlet private weak var rightSideMenuBarButtonItem: UIBarButtonItem!
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    private var messageState: State = State.creating
    private var tableCells: [TableCell] = []
    private var isAnimatedScrolling = false
    
    private var chatSender: ChatUser?
    private var selectedSenderMessage: Message?
    
    private var errorMessage: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        messageTextField.delegate = self
        tableView.dataSource = self
        
        customizeViewElements()
        registerTableViewNibs()
        loadMessages()
    }
    
    
    func setChatSender(_ chatSender: ChatUser?) {
        self.chatSender = chatSender
    }
    

    
    //MARK: - COMMON METHODS
    
    
    
    private func setUserInteraction(isEnabled state: Bool) {
        navigationController?.navigationBar.isUserInteractionEnabled = state
        view.isUserInteractionEnabled = state
    }

    
    private func hideEditingBlockView() {
        UIView.animate(withDuration: 0.3) {
            self.tableView.transform = .identity
            self.editBlockView.transform = CGAffineTransform(translationX: 0.0, y: +50.0)
        }
    }
    

    private func showEditingBlockView() {
        UIView.animate(withDuration: 0.2) {
            self.tableView.transform = CGAffineTransform(translationX: 0.0, y: -50.0)
            self.editBlockView.transform = .identity
        }
    }
    
    
    private func showDeletionScreensaver() {
        activateBlurEffectInDeletingView()
        deletingLabel.startBlink()
        deletingView.isHidden = false
    }
    
    
    private func activateBlurEffectInDeletingView() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = deletingView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        deletingView.addSubview(blurEffectView)
        deletingView.addSubview(deletingLabel)
    }
    
    
    private func hideDeletionScreensaver() {
        deletingView.isHidden = true
    }
    
    
    private func setSendButtonCreationAppearance() {
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.tintColor = UIColor.brandLightBlue
    }
    
    
    private func setSendButtonEditingAppearance() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .large)
        let largeBoldDoc = UIImage(systemName: "checkmark.circle.fill", withConfiguration: largeConfig)
        sendButton.setImage(largeBoldDoc, for: .normal)
        sendButton.tintColor = UIColor.brandMint
    }
    
    
    private func clearMessageTextField() {
        messageTextField.text = K.Case.emptyString
    }
    
    
    private func moveUpKeyboard() {
        messageTextField.becomeFirstResponder()
    }
    
    
    private func moveDownKeyboard() {
        messageTextField.resignFirstResponder()
    }
    
    
    private func stopTableViewCellsUpdating() {
        listener?.remove()
    }
    
    
    
    //MARK: - NIBS REGISTRATION
    
    
    
    private func registerTableViewNibs() {
        tableView.register(UINib(nibName: K.TableCell.greetingNibName, bundle: nil), forCellReuseIdentifier: K.TableCell.greetingNibIdentifier)
        tableView.register(UINib(nibName: K.TableCell.senderNibName, bundle: nil), forCellReuseIdentifier: K.TableCell.senderNibIdentifier)
        tableView.register(UINib(nibName: K.TableCell.receiverNibName, bundle: nil), forCellReuseIdentifier: K.TableCell.receiverNibIdentifier)
    }
    
    
    
    //MARK: - VIEW CUSTOMIZATION
    
    

    private func customizeViewElements() {
        customizeChatAvatar()
        customizeNavigationTitle()
        customizeEditBlockView()
        customizeMessageTextField()
    }
    
    
    private func customizeChatAvatar() {
        guard let safeSenderId = Auth.auth().currentUser?.uid else { return }
        
        db.collection(K.FStore.usersCollection).whereField(K.FStore.userIdField, isNotEqualTo: safeSenderId).getDocuments() { [weak self] (querySnapshot, error) in
            if let safeError = error {
                print("Chat avatar loading was failed: \(safeError)")
            } else {
                guard let documents = querySnapshot?.documents else { return }
                
                if documents.count > 1 {
                    DispatchQueue.main.async {
                        self?.setLeftBarButtonItem(with: UIImage.defaultGroupAvatar)
                    }
                } else if documents.count == 1 {
                    guard let safeAvatarUrl = documents.first?.data()[K.FStore.avatarURLField] as? String else { return }
                    
                    self?.downloadChatAvatar(stringURL: safeAvatarUrl)
                }
            }
        }
    }
    
    
    private func downloadChatAvatar(stringURL: String) {
        let ref = Storage.storage().reference(forURL: stringURL)
        
        let megaByte = Int64(1 * 1024 * 1024)
        
        ref.getData(maxSize: megaByte) { [weak self] data, error in
            if let safeError = error {
                print(safeError)
            } else {
                guard let safeData = data else { return }
                
                DispatchQueue.main.async {
                    self?.setLeftBarButtonItem(with: UIImage(data: safeData))
                }
            }
        }
    }
    
    
    private func setLeftBarButtonItem(with image: UIImage?){
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 38, height: 38)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(chatAvatarLeftBarButtonPressed), for: .touchUpInside)
        
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.layer.cornerRadius = CGFloat(19)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        let currWidth = barButtonItem.customView?.widthAnchor.constraint(equalToConstant: 38)
        currWidth?.isActive = true
        let currHeight = barButtonItem.customView?.heightAnchor.constraint(equalToConstant: 38)
        currHeight?.isActive = true
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    
    @objc private func chatAvatarLeftBarButtonPressed() {
        //for future
        print(#function)
    }
    
    
    
    private func customizeEditBlockView() {
        editBlockCancelButton.setTitle(K.Case.emptyString, for: .normal)
        editBlockCancelButton.tintColor = UIColor.brandDarkMint
        editBlockView.transform = CGAffineTransform(translationX: 0.0, y: +50.0)
    }
    
    
    private func customizeNavigationTitle() {
        guard let safeColor =  UIColor.brandLightMint,
              let safeFont = UIFont.getAvenirNextHeavy(size: 20)
        else { return }
        
        let titleLabel = UILabel()
        
        let titleAttribute: [NSAttributedString.Key: Any] = [
            .font: safeFont,
            .foregroundColor: safeColor
        ]

        let attributeAppName = NSMutableAttributedString(string: K.appName + " ", attributes: titleAttribute)

        titleLabel.attributedText = attributeAppName
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
    }
    

    private func customizeMessageTextField() {
        messageTextField.layer.cornerRadius = 18
        messageTextField.setLeftPaddingPoints(10)
        messageTextField.setRightPaddingPoints(10)
    }
    
    
    
    
    
    //MARK: - LOAD MESSAGES
    
    
    
    private func loadMessages() {
        listener = db.collection(K.FStore.messagesCollection).order(by: K.FStore.dateField).addSnapshotListener { [weak self] (querySnapshot, error) in
            if let safeError = error {
                print("Error load messages: \(safeError)")
            } else {
                guard let documents = querySnapshot?.documents else { return }
                
                self?.tableCells = [GreetingMessage()]
                
                for document in documents {
                    do {
                        let messageData = try document.data(as: MessageData.self)
                        
                        guard let cellRowNumber = self?.tableCells.count else { continue }
                        
                        let message = Message(cellRow: cellRowNumber, data: messageData)
                        
                        self?.tableCells.append(message)
                    }
                    catch {
                        print("Retrieving MessageData from Firestore was failed")
                        continue
                    }
                }
                
                DispatchQueue.main.async {
                    self?.showLoadedMessages()
                }
            }
        }
    }
    
    
    private func showLoadedMessages() {
        tableView.reloadData()
        
        if messageState == State.creating {
            let indexPath = IndexPath(row: tableCells.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top , animated: isAnimatedScrolling)
            
            if !isAnimatedScrolling {
                isAnimatedScrolling = true
            }
        }
    }

    
    
    //MARK: - SIDE MENU BUTTON
    
    
    
    @IBAction private func sideMenuRightBarButtonPressed(_ sender: UIBarButtonItem) {
        navigateToUserInfo()
    }
    
    
    
    //MARK: - SEND BUTTON
    
    
    
    @IBAction private func sendButtonPressed(_ sender: UIButton) {
        if messageState == State.creating {
            createMessage()
        } else if messageState == State.editing {
            editMessage()
        }
    }
    
    
    private func createMessage() {
        guard let safeMessageBody = messageTextField.text?.trim() else { return }

        if !safeMessageBody.isEmpty {
            guard let safeChatSender = chatSender else { return }
            
            let messageData = MessageData(
                date: String(Date().timeIntervalSince1970),
                userId: safeChatSender.data.userId,
                userFirstName: safeChatSender.data.firstName,
                textBody: safeMessageBody,
                isEdited: K.Case.no,
                userRGBColor: safeChatSender.data.userRGBColor)
            
            do {
                let _ = try db.collection(K.FStore.messagesCollection).addDocument(from: messageData) { [weak self] error in
                    if let safeError = error {
                        print("Message creation was failed: \(safeError)")
                    } else {
                        DispatchQueue.main.async {
                            self?.clearMessageTextField()
                        }
                    }
                }
            } catch let error {
                print("Message creation was failed: \(error)")
            }
        }
    }
    
    
    private func editMessage() {
        guard let safeMessageBody = messageTextField.text?.trim() else { return }
        
        if !safeMessageBody.isEmpty {
            guard var messageData = selectedSenderMessage?.data,
                  let messageId = messageData.documentId
            else { return }
            
            messageData.textBody = safeMessageBody
            messageData.isEdited = K.Case.yes

            let mergeFields = [K.FStore.textBodyField, K.FStore.isEdited]
            
            do {
                try
                db.collection(K.FStore.messagesCollection).document(messageId).setData(from: messageData, mergeFields: mergeFields) { [weak self] error in
                    if let safeError = error {
                        print("Message editing was failed: \(safeError)")
                    } else {
                        DispatchQueue.main.async {
                            self?.clearMessageTextField()
                            self?.finishMessageEditing()
                        }
                    }
                }
            } catch let error {
                print("Message editing was failed \(error)")
            }
        } else {
            finishMessageEditing()
            navigateToEditMessageWarning()
        }
    }
    
    
    private func finishMessageEditing() {
        messageState = State.creating
        setSendButtonCreationAppearance()
        hideEditingBlockView()
    }
    
    
    private func startMessageEditing() {
        messageState = State.editing
        setSendButtonEditingAppearance()
        showEditingBlockView()
        moveUpKeyboard()
    }
    
    
    
    //MARK: - CANCEL BUTTON
    
    
    
    @IBAction private func cancelButtonPressed(_ sender: UIButton) {
        clearMessageTextField()
        finishMessageEditing()
    }
}



//MARK: - EXTENSIONS:



//MARK: - TableView Cell SETTING



extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableCells.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableCells[indexPath.row]

        var uiTableViewCell = UITableViewCell()
        
        if tableCell is GreetingMessage {
            uiTableViewCell = tableView.dequeueReusableCell(withIdentifier: K.TableCell.greetingNibIdentifier, for: indexPath)
        } else if tableCell is Message {
            guard let message = tableCell as? Message
            else { return UITableViewCell() }
            
            if message.data.userId == Auth.auth().currentUser?.uid {
                uiTableViewCell = tableView.dequeueReusableCell(withIdentifier: K.TableCell.senderNibIdentifier, for: indexPath)
                
                guard let safeSenderMessageCell = uiTableViewCell as? SenderMessageCell
                else { return UITableViewCell() }
                
                safeSenderMessageCell.delegate = self
                safeSenderMessageCell.setData(message)
            } else {
                uiTableViewCell = tableView.dequeueReusableCell(withIdentifier: K.TableCell.receiverNibIdentifier, for: indexPath)
                
                guard let safeReceiverMessageCell = uiTableViewCell as? ReceiverMessageCell
                else { return UITableViewCell() }
                
                //Краще передавати struct Message чи class Message????????
                safeReceiverMessageCell.setData(message)
            }
        }
        
        return uiTableViewCell
    }
}



//MARK: - MessageCell DELEGATE



extension ChatViewController: SenderMessageCellDelegate {
    func messageSelected(_ messageCell: SenderMessageCell, selectedMessage: Message) {
        selectedSenderMessage = selectedMessage
        navigateToEditMenu()
    }
}



//MARK: - TextField DELEGATE



extension ChatViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        //Setting empty string allow keyboard hides down correctly.
        //Otherwise keyboard has floating size and after it hides layout becomes floating too. Maybe this issue depends on CLTypingLabel(pod) specific.
        clearMessageTextField()
    }
}



//MARK: - MESSAGE STATES



extension ChatViewController {
    private enum State {
        case creating, editing, deleting
    }
}



//MARK: - SEGUES



extension ChatViewController {
    private func navigateToEditMenu() {
        performSegue(withIdentifier: K.Segue.chatToEditMenu, sender: self)
    }
    
    
    private func navigateToUserInfo() {
        performSegue(withIdentifier: K.Segue.chatToUserInfo, sender: self)
    }
    
    
    private func navigateToEditMessageWarning() {
        performSegue(withIdentifier: K.Segue.chatToEditMessageWarning, sender: self)
    }
    
    
    private func navigateToWelcome() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    private func navigateToNewUserData() {
        performSegue(withIdentifier: K.Segue.chatToNewUserData, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.chatToEditMenu {
            if let destinationVC = segue.destination as? EditMenuViewController {
                destinationVC.setEditButtonPressedCallBack({ [weak self] in
                    self?.editSelectedMessage()
                })
                
                destinationVC.setDeleteButtonPressedCallBack({ [weak self] in
                    self?.deleteSelectedMessage()
                })
            }
        } else if segue.identifier == K.Segue.chatToUserInfo {
            moveDownKeyboard()
            
            if let destinationVC = segue.destination as? UserInfoViewController {
                destinationVC.setChatSender(chatSender)
                
                destinationVC.setEditAccountButtonPressedCallBack { [weak self] in
                    self?.editAccount()
                }
                
                destinationVC.setLogOutButtonPressedCallBack({ [weak self] in
                    self?.logOut()
                })
                
                destinationVC.setDeleteAccountButtonPressedCallBack({ [weak self] in
                    self?.deleteAccountTotally()
                })
            }
        } else if segue.identifier == K.Segue.chatToNewUserData {
            if let destinationVC = segue.destination as? NewUserDataViewController {
                destinationVC.setChatSender(chatSender, errorMessage: errorMessage)
            }
        }
    }
}




//MARK: - EditMenuVC CALLBACKS



extension ChatViewController {
    //MARK: - -editSelectedMessage()
    private func editSelectedMessage() {
        guard let selectedMessageTextBody = selectedSenderMessage?.data.textBody,
              let selectedMessageCellRow = selectedSenderMessage?.cellRow
        else { return }
        
        messageTextField.text = selectedMessageTextBody
        editBlockMessageTextLabel.text = selectedMessageTextBody
        
        startMessageEditing()
        
        let indexPath = IndexPath(row: selectedMessageCellRow, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    
    //MARK: - -deleteSelectedMessage()
    private func deleteSelectedMessage() {
        guard let selectedMessageId = selectedSenderMessage?.data.documentId
        else { return }
        
        messageState = State.deleting
        
        db.collection(K.FStore.messagesCollection).document(selectedMessageId).delete() { [weak self] error in
            if let safeError = error {
                print("Message deleting was failed: \(safeError)")
            }
            
            self?.messageState = State.creating
        }
    }
}



//MARK: - UserInfoVC CALLBACKS



extension ChatViewController {
    //MARK: - -editAccount()
    private func editAccount() {
        if let _ = chatSender {
            errorMessage = K.Case.emptyString
            navigateToNewUserData()
        }
    }
    
    
    
    //MARK: - -logOut()
    private func logOut() {
        setUserInteraction(isEnabled: false)
        
        do {
            try Auth.auth().signOut()
            navigateToWelcome()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            navigateToWelcome()
        }
    }
    
    
    
    //MARK: - -deleteAccountTotally()
    private func deleteAccountTotally() {
        if let safeUser = Auth.auth().currentUser {
            showDeletionScreensaver()
            setUserInteraction(isEnabled: false)
            
            deleteAccountAvatar(forUser: safeUser)
        }
    }
    
    
    
    private func deleteAccountAvatar(forUser user: User) {
        Storage.storage().reference().child(K.FStore.avatarsCollection).child(user.uid).delete { [weak self] error in
            if let safeError = error {
                print("Avatar deletion was failed: \(safeError)")
                
                //After error occuring NewUserDataVC will run to user's data and avatar recreating if some of them doesn't exist or something goes wrong. Then user will back to ChatVC and can try delete account again.
                self?.failedToDeleteAccount()
            } else {
                self?.deleteAccountData(forUser: user)
            }
        }
    }
    
    
    private func deleteAccountData(forUser user: User) {
        db.collection(K.FStore.usersCollection).document(user.uid).delete { [weak self] error in
            if let safeError = error {
                print("User data deletion was failed: \(safeError)")
                self?.failedToDeleteAccount()
            } else {
                self?.deleteAccountMessages(forUser: user)
            }
        }
    }
    
    
    private func deleteAccountMessages(forUser user: User) {
        stopTableViewCellsUpdating()

        db.collection(K.FStore.messagesCollection)
            .whereField(K.FStore.userIdField, isEqualTo: user.uid)
            .getDocuments() { [weak self] (querySnapshot, error) in
            if let safeError = error {
                print("User messages getting was failed: \(safeError)")
                self?.failedToDeleteAccount()
            } else {
                guard let messages = querySnapshot?.documents else {
                    self?.failedToDeleteAccount()
                    return
                }

                if messages.isEmpty {
                    self?.deleteAccount(forUser: user)
                } else {
                    var messagesCount = messages.count
                    
                    for message in messages {
                        message.reference.delete() { [weak self] error in
                            if let safeError = error {
                                print("User message deletion was failed: \(safeError)")
                                self?.failedToDeleteAccount()
                            } else {
                                messagesCount -= 1
                                
                                if messagesCount <= 0 {
                                    self?.deleteAccount(forUser: user)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    
    private func deleteAccount(forUser user: User) {
        user.delete { [weak self] error in
            if let safeError = error {
                print("User deletion was failed: \(safeError)")
                self?.failedToDeleteAccount()
            } else {
                self?.logOut()
            }
        }
    }
    
    
    private func failedToDeleteAccount() {
        errorMessage = "Account deletion was failed. Click \"Continue\" and try again."
        deletingLabel.stopBlink()
        navigateToNewUserData()
    }
}

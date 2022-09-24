import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import IQKeyboardManagerSwift

class ChatViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private weak var editBlockView: UIView!
    @IBOutlet private weak var editBlockMessageTextLabel: UILabel!
    @IBOutlet private weak var editBlockCancelButton: UIButton!
    
    @IBOutlet private weak var messageTextField: UITextField!
    @IBOutlet private weak var sendButton: UIButton!
    
    @IBOutlet private weak var deletingView: UIView!
    @IBOutlet private weak var deletingLabel: UILabel!
    
    @IBOutlet private weak var rightSideMenuBarButtonItem: UIBarButtonItem!
    private var leftChatAvatarBarButton: UIButton?
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    private var messageState: State = State.creating
    private var tableCells: [TableCell] = []
    
    private var messageRow: Int?
    private var messageId: String?
    private var messageBody: String?
    
    private var senderFirstName: String?
    private var senderLastName: String?
    private var senderAvatar: UIImage?
    private var senderRGBColor: String?
    
    var isMoreThanTwoChatUsers = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextField.delegate = self
        tableView.dataSource = self
        
        registerTableViewNibs()
        
        customizeNavigationTitle()
        customizeViewElements()
        
        loadChatInfo()
        loadSenderInfo()
    }
    
    
    
    //MARK: - COMMON METHODS
    
    
    
    private func disableViewUserInteraction() {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        view.isUserInteractionEnabled = false
    }
    
    
    private func hideEditBlockView() {
        UIView.animate(withDuration: 0.3) {
            self.tableView.transform = .identity
            self.editBlockView.transform = CGAffineTransform(translationX: 0.0, y: +50.0)
        }
    }
    
    
    private func showEditBlockView() {
        UIView.animate(withDuration: 0.2) {
            self.tableView.transform = CGAffineTransform(translationX: 0.0, y: -50.0)
            self.editBlockView.transform = .identity
        }
    }
    
    
    private func showDeletingView() {
        deletingView.isHidden = false
        deletingLabel.blink()
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = deletingView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        deletingView.addSubview(blurEffectView)
        deletingView.addSubview(deletingLabel)
    }
    
    
    private func setSendButtonCreatingAppearance() {
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
    
    
    private func clearMessageCellData() {
        messageRow = nil
        messageId = nil
        messageBody = nil
    }
    
    
    private func moveUpKeyboard() {
        messageTextField.becomeFirstResponder()
    }
    
    
    private func moveDownKeyboard() {
        messageTextField.resignFirstResponder()
    }
    
    
    
    //MARK: - NIBS REGISTRATION
    
    
    
    private func registerTableViewNibs() {
        tableView.register(UINib(nibName: K.TableCell.greetingNibName, bundle: nil), forCellReuseIdentifier: K.TableCell.greetingNibIdentifier)
        tableView.register(UINib(nibName: K.TableCell.senderNibName, bundle: nil), forCellReuseIdentifier: K.TableCell.senderNibIdentifier)
        tableView.register(UINib(nibName: K.TableCell.receiverNibName, bundle: nil), forCellReuseIdentifier: K.TableCell.receiverNibIdentifier)
    }
    
    
    
    //MARK: - VIEW CUSTOMIZATION
    
    
    
    private func customizeNavigationTitle() {
        sendButton.isUserInteractionEnabled = false
        
        guard let safeFont = UIFont(name: K.BrandFonts.avenirNextHeavy, size: 20),
              let safeColor =  UIColor.brandLightMint
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
    
    
    private func customizeViewElements() {
        editBlockView.transform = CGAffineTransform(translationX: 0.0, y: +50.0)
        editBlockCancelButton.setTitle(K.Case.emptyString, for: .normal)
        editBlockCancelButton.tintColor = UIColor.brandDarkMint
        
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
                self?.tableCells = [ GreetingMessage() ]
                
                guard let documents = querySnapshot?.documents else { return }
                
                for document in documents {
                    guard let safeUserId = document.data()[K.FStore.userIdField] as? String,
                          let safeUserFirstName = document.data()[K.FStore.userFirstNameField] as? String,
                          let safeTextBody = document.data()[K.FStore.textBodyField] as? String,
                          let safeDateString = document.data()[K.FStore.dateField] as? String,
                          let safeIsEdited = document.data()[K.FStore.isEdited] as? String,
                          let safeUserRGBColor = document.data()[K.FStore.userRGBColorField] as? String
                    else { return }
                    
                    guard let safeTimestamp = self?.formatDateString(milliseconds: safeDateString),
                          let tableCellsCount = self?.tableCells.count
                    else { return }
                    
                    let message = Message(row: tableCellsCount, id: document.documentID, timestamp: safeTimestamp, userId: safeUserId, userFirstName: safeUserFirstName, body: safeTextBody, isEdited: safeIsEdited, userRGBColor: safeUserRGBColor)
                    
                    self?.tableCells.append(message)
                }
                
                if self?.messageState == State.creating {
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                        
                        guard let tableCellsCount = self?.tableCells.count else { return }
                        
                        let indexPath = IndexPath(row: tableCellsCount - 1, section: 0)
                        self?.tableView.scrollToRow(at: indexPath, at: .top , animated: true)
                    }
                } else {
                    self?.messageState = State.creating
                }
            }
        }
    }
    
    
    private func formatDateString(milliseconds: String) -> String {
        var formatedDateString = String()
        
        if let msDouble = Double(milliseconds) {
            let dateObject = Date(timeIntervalSince1970: TimeInterval(msDouble))
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = K.Date.getFormat
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = K.Date.printFormat
            
            if let safeGottedDate = dateFormatterGet.date(from: dateObject.description) {
                formatedDateString = dateFormatterPrint.string(from: safeGottedDate)
            }
        }
        
        return formatedDateString
    }
    
    
    
    //MARK: - LOAD CHAT INFO
    
    
    
    private func loadChatInfo() {
        guard let safeSenderId = Auth.auth().currentUser?.uid else { return }
        
        db.collection(K.FStore.usersCollection).whereField(K.FStore.userIdField, isNotEqualTo: safeSenderId).getDocuments() { [weak self] (querySnapshot, error) in
            if let safeError = error {
                print("Error load users: \(safeError)")
            } else {
                guard let documents = querySnapshot?.documents else { return }
                
                DispatchQueue.main.async {
                    if documents.count > 1 {
                        self?.isMoreThanTwoChatUsers = true
                        self?.setUpChatAvatarToLeftBarItem(image: UIImage(named: K.Image.defaultGroupAvatar))
                    } else {
                        guard let safeAvatarUrl = documents.first?.data()[K.FStore.avatarURLField] as? String
                        else { return }
                        
                        if safeAvatarUrl == K.Case.no {
                            self?.setUpChatAvatarToLeftBarItem(image: UIImage(named: K.Image.defaultAvatar))
                        } else {
                            self?.loadChatAvatar(urlString: safeAvatarUrl)
                        }
                    }
                }
            }
            self?.loadMessages()
        }
    }
    
    
    private func loadChatAvatar(urlString: String) {
        let ref = Storage.storage().reference(forURL: urlString)
        
        let megaByte = Int64(1 * 1024 * 1024)
        
        ref.getData(maxSize: megaByte) { [weak self] data, error in
            if let safeError = error {
                print(safeError)
            } else {
                guard let safeData = data else { return }
                self?.setUpChatAvatarToLeftBarItem(image: UIImage(data: safeData))
            }
        }
    }
    
    
    private func setUpChatAvatarToLeftBarItem(image: UIImage?){
        let groupImageButton = UIButton(type: .custom)
        groupImageButton.frame = CGRect(x: 0.0, y: 0.0, width: 38, height: 38)
        groupImageButton.setImage(image, for: .normal)
        groupImageButton.addTarget(self, action: #selector(chatAvatarLeftBarButtonPressed), for: .touchUpInside)
        
        groupImageButton.imageView?.contentMode = .scaleAspectFill
        groupImageButton.imageView?.layer.cornerRadius = CGFloat(19)
        leftChatAvatarBarButton = groupImageButton
        
        let menuBarItem = UIBarButtonItem(customView: groupImageButton)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 38)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 38)
        currHeight?.isActive = true
        navigationItem.leftBarButtonItem = menuBarItem
    }
    
    
    @objc private func chatAvatarLeftBarButtonPressed() {
        print(#function)
    }
    
    
    
    //MARK: - LOAD SENDER INFO
    
    
    
    private func loadSenderInfo() {
        guard let safeSenderId = Auth.auth().currentUser?.uid else { return }
        
        db.collection(K.FStore.usersCollection).document(safeSenderId).getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                guard let safeFirstName = document.data()?[K.FStore.firstNameField] as? String,
                      let safeLastName = document.data()?[K.FStore.lastNameField] as? String,
                      let safeAvatarUrl = document.data()?[K.FStore.avatarURLField] as? String,
                      let safeUserRGBColor = document.data()?[K.FStore.userRGBColorField] as? String
                else { return }
                
                self?.senderFirstName = safeFirstName
                self?.senderLastName = safeLastName
                self?.senderRGBColor = safeUserRGBColor
                
                self?.sendButton.isUserInteractionEnabled = true
                
                if safeAvatarUrl == K.Case.no {
                    self?.senderAvatar = UIImage(named: K.Image.defaultAvatar)
                } else {
                    self?.loadSenderAvatar(urlString: safeAvatarUrl)
                }
            } else {
                print("Sender info were not existed")
            }
        }
    }
    
    
    private func loadSenderAvatar(urlString: String) {
        let ref = Storage.storage().reference(forURL: urlString)
        
        let megaByte = Int64(1 * 1024 * 1024)
        
        ref.getData(maxSize: megaByte) { [weak self] data, error in
            if let safeError = error {
                print(safeError)
            } else {
                guard let safeData = data else { return }
                self?.senderAvatar = UIImage(data: safeData)
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
            if messageTextField.text != K.Case.emptyString {
                guard let safeUserId = Auth.auth().currentUser?.uid,
                      let safeSenderFirstName = senderFirstName,
                      let safeMessageBody = messageTextField.text,
                      let safeSenderRGBColor = senderRGBColor
                else { return }
                
                clearMessageTextField()
                
                let docData: [String: Any] = [
                    K.FStore.userIdField: safeUserId,
                    K.FStore.userFirstNameField: safeSenderFirstName,
                    K.FStore.textBodyField: safeMessageBody,
                    K.FStore.dateField: String(Date().timeIntervalSince1970),
                    K.FStore.isEdited: K.Case.no,
                    K.FStore.userRGBColorField: safeSenderRGBColor
                ]
                
                db.collection(K.FStore.messagesCollection).addDocument(data: docData) { error in
                    if let safeError = error {
                        print("Error adding document: \(safeError)")
                    }
                }
            }
        } else if messageState == State.editing {
            if messageTextField.text != K.Case.emptyString {
                guard let safeMessageId = messageId,
                      let editedMessage = messageTextField.text
                else { return }
                
                clearMessageTextField()
                
                let docData: [String: Any] = [
                    K.FStore.textBodyField: editedMessage,
                    K.FStore.isEdited: K.Case.yes
                ]
                
                db.collection(K.FStore.messagesCollection).document(safeMessageId).updateData(docData) { [weak self] error in
                    if let safeError = error {
                        print("Error updating document: \(safeError)")
                    } else {
                        DispatchQueue.main.async {
                            self?.setSendButtonCreatingAppearance()
                            self?.hideEditBlockView()
                            self?.tableView.reloadData()
                        }
                    }
                }
            } else {
                messageState = State.creating
                
                DispatchQueue.main.async {
                    self.hideEditBlockView()
                    self.setSendButtonCreatingAppearance()
                }
                
                navigateToCancelEdit()
            }
            
            clearMessageCellData()
        }
    }
    
    
    
    //MARK: - CANCEL BUTTON
    
    
    
    @IBAction private func cancelButtonPressed(_ sender: UIButton) {
        hideEditBlockView()
        tableView.reloadData()
        setSendButtonCreatingAppearance()
        clearMessageTextField()
        messageState = State.creating
        clearMessageCellData()
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
            
            return uiTableViewCell
        } else {
            guard let message = tableCell as? Message else { return uiTableViewCell }
            
            let timeStamp = (message.isEdited == K.Case.yes ? "edited " : K.Case.emptyString) + message.timestamp
            
            if message.userId == Auth.auth().currentUser?.uid {
                uiTableViewCell = tableView.dequeueReusableCell(withIdentifier: K.TableCell.senderNibIdentifier, for: indexPath)
                
                if let safeSenderMessageCell = uiTableViewCell as? SenderMessageCell {
                    safeSenderMessageCell.delegate = self
                    
                    safeSenderMessageCell.setSenderMessageCellData(row: message.row, id: message.id, body: message.body, timestamp: timeStamp)
                    
                    return safeSenderMessageCell
                }
            } else {
                uiTableViewCell = tableView.dequeueReusableCell(withIdentifier: K.TableCell.receiverNibIdentifier, for: indexPath)
                
                if let safeReceiverMessageCell = uiTableViewCell as? ReceiverMessageCell {
                    let rgb = message.userRGBColor.components(separatedBy: ",").compactMap{Double($0)}
                    
                    let userColor = UIColor(red: rgb[0], green: rgb[1], blue: rgb[2], alpha: 1.0)
                    
                    safeReceiverMessageCell.setReceiverMessageCellData(userColor: userColor, userFirstName: message.userFirstName, body: message.body, timestamp: timeStamp)
                    
                    return safeReceiverMessageCell
                }
            }
        }
        
        return uiTableViewCell
    }
}



//MARK: - MessageCell DELEGATE



extension ChatViewController: SenderMessageCellDelegate {
    func messageSelected(_ messageCell: SenderMessageCell, row: Int, id: String, body: String) {
        messageRow = row
        messageId = id
        messageBody = body
        
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
        case creating, editing
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
    
    
    private func navigateToCancelEdit() {
        performSegue(withIdentifier: K.Segue.chatToCancelEdit, sender: self)
    }
    
    
    private func navigateToWelcome() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.chatToEditMenu {
            if let destinationVC = segue.destination as? EditMenuViewController {
                destinationVC.editButtonPressedCallBack = { [weak self] in
                    self?.editMessageBody()
                }
                
                destinationVC.deleteButtonPressedCallBack = { [weak self] in
                    self?.deleteMessage()
                }
            }
        } else if segue.identifier == K.Segue.chatToUserInfo {
            moveDownKeyboard()
            
            if let destinationVC = segue.destination as? UserInfoViewController {
                if let safeSenderFirstName = senderFirstName,
                   let safeSenderLastName = senderLastName,
                   let safeSenderAvatar = senderAvatar {
                    destinationVC.setUserInfo(senderFirstName: safeSenderFirstName, senderLastName: safeSenderLastName, senderAvatar: safeSenderAvatar)
                    
                    destinationVC.logOutButtonPressedCallBack = { [weak self] in
                        self?.logOut()
                    }
                    
                    destinationVC.deleteAccountButtonPressedCallBack = { [weak self] in
                        self?.deleteAccountAndData()
                    }
                }
                
            }
        }
    }
}




//MARK: - EditMenuVC CALLBACKS



extension ChatViewController {
    //MARK: - -editMessageBody()
    private func editMessageBody() {
        messageState = State.editing
        messageTextField.text = messageBody
        
        if let safeRow = messageRow {
            let indexPath = IndexPath(row: safeRow, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
        
        moveUpKeyboard()
        
        setSendButtonEditingAppearance()
        editBlockMessageTextLabel.text = messageBody
        showEditBlockView()
    }
    
    
    //MARK: - -deleteMessage()
    private func deleteMessage() {
        if let safeMessageId = messageId {
            db.collection(K.FStore.messagesCollection).document(safeMessageId).delete() { error in
                if let safeError = error {
                    print("Error removing document: \(safeError)")
                }
            }
        }
        
        clearMessageCellData()
    }
}



//MARK: - UserInfoVC CALLBACKS



extension ChatViewController {
    //MARK: - -deleteAccountAndData()
    private func deleteAccountAndData() {
        disableViewUserInteraction()
        showDeletingView()
        deleteUserInfo()
    }
    
    
    private func deleteUserInfo() {
        guard let safeCurrentUserUid = Auth.auth().currentUser?.uid else { return }
        
        db.collection(K.FStore.usersCollection).document(safeCurrentUserUid).delete { [weak self] error in
            if let safeError = error {
                print("Deleting user info was failed: \(safeError)")
            } else {
                self?.deleteUserMessages()
            }
        }
    }
    
    
    private func deleteUserMessages() {
        guard let safeCurrentUserUid = Auth.auth().currentUser?.uid else { return }
        
        listener?.remove()
        
        db.collection(K.FStore.messagesCollection).whereField(K.FStore.userIdField, isEqualTo: safeCurrentUserUid).getDocuments() { [weak self] (querySnapshot, error) in
            if let safeError = error {
                print("Error getting user messages: \(safeError)")
            } else {
                guard let documents = querySnapshot?.documents else { return }
                
                if documents.isEmpty {
                    self?.deleteUserAvatar()
                } else {
                    var documentIdArray = [String]()
                    
                    for document in documents {
                        documentIdArray.append(document.documentID)
                    }
                    
                    for documentId in documentIdArray {
                        self?.db.collection(K.FStore.messagesCollection).document(documentId).delete() { [weak self] error in
                            if let safeError = error {
                                print("Error removing user message: \(safeError)")
                            } else {
                                if documentId == documentIdArray.last {
                                    self?.deleteUserAvatar()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    private func deleteUserAvatar() {
        guard let safeCurrentUserUid = Auth.auth().currentUser?.uid else { return }
        
        Storage.storage().reference().child(K.FStore.avatarsCollection).child(safeCurrentUserUid).delete { [weak self] error in
            if let _ = error {
                self?.deleteCurrentUser()
            } else {
                self?.deleteCurrentUser()
            }
        }
    }
    
    
    private func deleteCurrentUser() {
        Auth.auth().currentUser?.delete { [weak self] error in
            if let safeError = error {
                print(safeError)
            } else {
                self?.logOut()
            }
        }
    }
    
    
    //MARK: - -logOut()
    private func logOut() {
        listener?.remove()
        disableViewUserInteraction()
        
        do {
            try Auth.auth().signOut()
            navigateToWelcome()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

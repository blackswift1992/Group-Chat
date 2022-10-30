import UIKit

class MessageMenuViewController: UIViewController {
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!

    private var editButtonPressedCallBack: (() -> ())?
    private var deleteButtonPressedCallBack: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViewElements()
    }
    
    //any touch out of the UI element heads back to previous view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - Public methods


extension MessageMenuViewController {
    func setEditButtonPressedCallBack(_ editCallBack: (() -> ())?) {
        editButtonPressedCallBack = editCallBack
    }
    
    func setDeleteButtonPressedCallBack(_ deleteCallBack: (() -> ())?) {
        deleteButtonPressedCallBack = deleteCallBack
    }
}


//MARK: - @IBActions


private extension MessageMenuViewController {
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) {
            self.deleteButtonPressedCallBack?()
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        dismiss(animated: false) {
            self.editButtonPressedCallBack?()
        }
    }
}


//MARK: - Set up methods


private extension MessageMenuViewController {
    func customizeViewElements() {
        deleteButton.layer.cornerRadius = 18
        editButton.layer.cornerRadius = 18
    }
}


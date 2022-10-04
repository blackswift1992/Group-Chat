import UIKit

class MessageMenuViewController: UIViewController {
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!

    private var editButtonPressedCallBack: (() -> ())?
    private var deleteButtonPressedCallBack: (() -> ())?
    
    
    func setEditButtonPressedCallBack(_ editCallBack: (() -> ())?) {
        editButtonPressedCallBack = editCallBack
    }
    
    
    func setDeleteButtonPressedCallBack(_ deleteCallBack: (() -> ())?) {
        deleteButtonPressedCallBack = deleteCallBack
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViewElements()
    }

    
    private func customizeViewElements() {
        deleteButton.layer.cornerRadius = 18
        editButton.layer.cornerRadius = 18
    }
    
    
    @IBAction private func deleteButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) {
            self.deleteButtonPressedCallBack?()
        }
    }
    
    
    @IBAction private func editButtonPressed(_ sender: UIButton) {
        dismiss(animated: true) {
            self.editButtonPressedCallBack?()
        }
    }

    
    //any touch out of the UI element heads back to previous view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismiss(animated: true, completion: nil)
    }
}



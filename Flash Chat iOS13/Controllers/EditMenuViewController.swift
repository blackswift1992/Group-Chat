import UIKit

class EditMenuViewController: UIViewController {
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!

    var editButtonPressedCallBack: (() -> ())?
    var deleteButtonPressedCallBack: (() -> ())?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeViewElements()
    }

    
    private func customizeViewElements() {
        deleteButton.layer.cornerRadius = 18
        editButton.layer.cornerRadius = 18
    }
    
    
    @IBAction private func deleteButtonPressed(_ sender: UIButton) {
        deleteButtonPressedCallBack?()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction private func editButtonPressed(_ sender: UIButton) {
        editButtonPressedCallBack?()
        self.dismiss(animated: true, completion: nil)
    }

    
    //any touch out of the UI element heads back to previous view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        dismiss(animated: true, completion: nil)
    }
}



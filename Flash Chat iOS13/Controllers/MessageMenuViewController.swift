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


//MARK: - Private methods


private extension MessageMenuViewController {
    @objc func respondToGesture() {
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - Set up methods


private extension MessageMenuViewController {
    func customizeViewElements() {
        deleteButton.layer.cornerRadius = 18
        editButton.layer.cornerRadius = 18
        setGestureRecognizerToView()
    }
    
    func setGestureRecognizerToView() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(respondToGesture))
        view.addGestureRecognizer(gestureRecognizer)
        view.isUserInteractionEnabled = true
    }
}


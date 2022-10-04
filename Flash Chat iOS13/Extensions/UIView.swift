import UIKit

extension UIView{
     func startBlink() {
         self.alpha = 0.2
         UIView.animate(withDuration: 1, delay: 0.0, options: [.curveLinear, .repeat, .autoreverse], animations: {self.alpha = 1.0}, completion: nil)
     }
    
    func stopBlink() {
        layer.removeAllAnimations()
        alpha = 1
    }
}

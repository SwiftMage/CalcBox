import SwiftUI
import UIKit

class KeyboardObserver: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    @Published var isKeyboardVisible: Bool = false
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        DispatchQueue.main.async {
            self.keyboardHeight = keyboardFrame.height
            self.isKeyboardVisible = true
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        DispatchQueue.main.async {
            self.keyboardHeight = 0
            self.isKeyboardVisible = false
        }
    }
}
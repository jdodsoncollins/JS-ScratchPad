import SwiftUI
import UIKit

/// A SwiftUI wrapper for UITextView that disables smart quotes, dashes, autocorrect, etc.
struct PlainTextEditor: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        // Disable iOS "smart" features:
        textView.autocorrectionType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.autocapitalizationType = .none
        
        // Match some typical TextEditor styling:
        textView.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
        textView.isScrollEnabled = true
        
        // Set delegate so we can keep the SwiftUI @Binding in sync
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Update UITextView text only if it differs, to avoid losing caret position
        if uiView.text != text {
            uiView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: PlainTextEditor
        
        init(_ parent: PlainTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // Update the SwiftUI state when user types
            parent.text = textView.text
        }
    }
}

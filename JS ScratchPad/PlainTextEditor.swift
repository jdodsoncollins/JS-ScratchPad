import SwiftUI
import UIKit
import Highlightr

struct PlainTextEditor: UIViewRepresentable {
    @Binding var text: String
    
    // Access the user's current color scheme from the environment
    @Environment(\.colorScheme) private var colorScheme
    
    let highlightr = Highlightr()
    
    init(text: Binding<String>) {
        self._text = text
        // Remove the hard-coded theme here so we can set it dynamically later
    }
    
    // MARK: - UIViewRepresentable
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        textView.autocorrectionType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.autocapitalizationType = .none
        
        textView.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .regular)
        textView.isScrollEnabled = true
        
        textView.delegate = context.coordinator
        textView.text = text
        
        // Apply theme for the first time
        applyTheme()
        context.coordinator.applyHighlightingImmediately(to: textView, text: text)
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            applyTheme()
            context.coordinator.applyHighlightingImmediately(to: uiView, text: text)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, UITextViewDelegate {
        let parent: PlainTextEditor
        var defaultLanguage: String = "javascript"
        
        private var highlightWorkItem: DispatchWorkItem?
        
        init(_ parent: PlainTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            
            // Debounce logic for large files / frequent typing
            highlightWorkItem?.cancel()
            
            let workItem = DispatchWorkItem { [weak self, weak textView] in
                guard let self = self, let textView = textView else { return }
                self.parent.applyTheme()
                self.applyHighlightingImmediately(to: textView, text: self.parent.text)
            }
            
            highlightWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        }
        
        func applyHighlightingImmediately(to textView: UITextView, text: String) {
            let cursorRange = textView.selectedRange
            
            if let highlighted = parent.highlightr?.highlight(text, as: defaultLanguage) {
                textView.attributedText = highlighted
            } else {
                textView.attributedText = NSAttributedString(string: text)
            }
            
            // Restore caret
            let maxPosition = textView.attributedText.length
            let newCursor = min(cursorRange.location, maxPosition)
            textView.selectedRange = NSMakeRange(newCursor, 0)
        }
    }
}

// MARK: - Theme Handling
private extension PlainTextEditor {
    /// Decide which theme to use based on the current color scheme
    func applyTheme() {
        if colorScheme == .dark {
            highlightr?.setTheme(to: "atom-one-dark")
        } else {
            highlightr?.setTheme(to: "atom-one-light")
        }
    }
}

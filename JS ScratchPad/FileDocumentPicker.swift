import SwiftUI
import UniformTypeIdentifiers

/// A document type for `.js` files.
struct JSFileDocument: FileDocument {
    var text: String = ""
    
    static var readableContentTypes = [UTType(filenameExtension: "js")!]
    
    init(text: String = "") {
        self.text = text
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents,
           let content = String(data: data, encoding: .utf8) {
            self.text = content
        } else {
            self.text = ""
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8) ?? Data()
        return FileWrapper(regularFileWithContents: data)
    }
}

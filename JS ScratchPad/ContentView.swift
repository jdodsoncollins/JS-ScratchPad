//
//  ContentView.swift
//  JS ScratchPad
//
//  Created by Jeremy Collins on 10/7/24.
//


import SwiftData
import SwiftUI
import JavaScriptCore

// MARK: - Main App Structure
struct JavaScriptExecutorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - ContentView with TabView
struct ContentView: View {
    @State private var inputText = "console.log('Hello, world!');"
    @State private var outputText = "Output will be shown here"
    
    var body: some View {
        VStack {
            Text("JavaScript Scratch Pad")
                .font(.largeTitle)
                .padding(.top, 10)
            
            Text("Enter JavaScript Code:")
                .font(.headline)
                .padding()
            
            // Multi-line Text Editor for JS Code
            TextEditor(text: $inputText)
                .font(.system(.body, design: .monospaced))
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .border(Color.gray, width: 1)
                .padding()
                .frame(height: 200)
            
            // Button to Execute JavaScript
            Button(action: {
                outputText = executeJavaScript(inputText)
            }) {
                Text("Run JavaScript")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            // Display the result of JavaScript execution
            TextEditor(text: $outputText)
                .font(.system(.body, design: .monospaced))
                .border(Color.gray, width: 1)
                .padding()
                .frame(height: 200)
                .disabled(true) // Make it read-only
        }
        .padding()
    }
    
    // Function to execute JavaScript using JavaScriptCore
    func executeJavaScript(_ jsCode: String) -> String {
        let context = JSContext()
        
        guard let context = context else {
            return "Failed to create JavaScript context."
        }
        
        var consoleOutput = ""
        
        let consoleLog: @convention(block) (String) -> Void = { message in
            consoleOutput += message + "\n" // Append message to consoleOutput
        }
        
        let consoleObject = JSValue(newObjectIn: context)
        consoleObject?.setObject(consoleLog, forKeyedSubscript: "log" as NSString)
        context.globalObject.setValue(consoleObject, forProperty: "console")
        
        // Execute the JS code and capture the result
        let result = context.evaluateScript(jsCode)
        
        if !consoleOutput.isEmpty {
            return consoleOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return result?.toString() ?? "No Output or undefined"
    }
}

// MARK: - InputView for JavaScript code input
struct InputView: View {
    @Binding var inputText: String
    @Binding var outputText: String
    
    var body: some View {
        VStack {
            Text("Enter JavaScript Code:")
                .font(.headline)
                .padding()
            
            // Multi-line Text Editor for JS Code
            TextEditor(text: $inputText)
                .font(.system(.body, design: .monospaced))
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .border(Color.gray, width: 1)
                .padding()
                .frame(height: 300)
            
            // Button to Execute JavaScript
            Button(action: {
                outputText = executeJavaScript(inputText)
            }) {
                Text("Run JavaScript")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
    }
    
    // Function to execute JavaScript using JavaScriptCore
    func executeJavaScript(_ jsCode: String) -> String {
        let context = JSContext()
        
        guard let context = context else {
            return "Failed to create JavaScript context."
        }
        
        var consoleOutput = ""
        
        let logHandler: @convention(block) (String) -> Void = { message in
            consoleOutput += message + "\n" // Append message to consoleOutput
        }
        
        let consoleObject = JSValue(newObjectIn: context)
        consoleObject?.setObject(logHandler, forKeyedSubscript: "log" as NSString)
        
        context.globalObject.setValue(consoleObject, forProperty: "console")
        
        let result = context.evaluateScript(jsCode)
        
        if let resultString = result?.toString(), !resultString.isEmpty, resultString != "undefined" {
            consoleOutput += "\nResult: \(resultString)"
        }
        
        return consoleOutput.isEmpty ? "No Output" : consoleOutput
    }
}

// MARK: - OutputView for displaying the result of JS execution
struct OutputView: View {
    @Binding var outputText: String // JS output text
    
    var body: some View {
        VStack {
            Text("JavaScript Output:")
                .font(.headline)
                .padding()
            
            // Display the result of the JavaScript execution
            TextEditor(text: $outputText)
                .border(Color.gray, width: 1)
                .padding()
                .frame(height: 300)
                .disabled(true) // Make it read-only
            
            Spacer()
        }
    }
}

// MARK: - PreviewProvider for ContentView
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - PreviewProvider for InputView
struct InputView_Previews: PreviewProvider {
    @State static var inputText = "console.log('Hello, World!')"
    @State static var outputText = "No Output"
    
    static var previews: some View {
        InputView(inputText: $inputText, outputText: $outputText)
    }
}

// MARK: - PreviewProvider for OutputView
struct OutputView_Previews: PreviewProvider {
    @State static var outputText = "Output will be shown here"
    
    static var previews: some View {
        OutputView(outputText: $outputText)
    }
}

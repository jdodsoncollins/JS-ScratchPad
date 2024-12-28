import SwiftUI
import JavaScriptCore

struct ContentView: View {
    @Binding var document: JSFileDocument
    
    @State private var outputText: String = ""
    
    @State private var bottomPanelOffset: CGFloat = 500
    
    @GestureState private var dragOffset: CGFloat = 0
    
    var body: some View {
            ZStack(alignment: .bottom) {
                
                // 1) Main Content
                NavigationView {
                    GeometryReader { geo in
                        VStack {
                            Text("JavaScript Scratch Pad")
                                .font(.largeTitle)
                                .padding(.top, 10)
                            
                            PlainTextEditor(text: $document.text)
                                .border(Color.gray, width: 1)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .frame(minHeight: 200)

                            Spacer().frame(height: 20)

                            Button("Run JavaScript") {
                                outputText = executeJavaScript(document.text)
                                withAnimation(.spring()) {
                                    bottomPanelOffset = 200
                                }
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 40)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            
                            Spacer().frame(height: 20)
                        }
                        .padding(.top)
                    }
                }
                .zIndex(0)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(radius: 8)
                    
                    OutputView(outputText: $outputText)
                }
                .frame(height: 400)
                .offset(y: bottomPanelOffset + dragOffset)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation.height
                        }
                        .onEnded { value in
                            let newOffset = bottomPanelOffset + value.translation.height
                            if newOffset > 400 {
                                // Hide fully
                                withAnimation(.spring()) {
                                    bottomPanelOffset = 500
                                }
                            } else {
                                // Show fully
                                withAnimation(.spring()) {
                                    bottomPanelOffset = 0
                                }
                            }
                        }
                )
                .animation(.spring(), value: bottomPanelOffset + dragOffset)
                .zIndex(1)
            }
        }
    
    func executeJavaScript(_ jsCode: String) -> String {
        guard let context = JSContext() else {
            return "Failed to create JavaScript context."
        }
        
        var consoleOutput = ""
        
        let swiftConsoleLog: @convention(block) (String) -> Void = { message in
            consoleOutput += message + "\n"
        }
        
        context.setObject(swiftConsoleLog, forKeyedSubscript: "_swiftConsoleLog" as NSString)
        
        let consoleObject = JSValue(newObjectIn: context)
        consoleObject?.setObject(swiftConsoleLog, forKeyedSubscript: "log" as NSString)
        context.globalObject.setValue(consoleObject, forProperty: "console")
        
        let consolePolyfill = #"""
        function formatValue(val) {
          // If array, recursively format each element
          if (Array.isArray(val)) {
            return "[" + val.map(function(elem) {
              return formatValue(elem);
            }).join(", ") + "]";
          } 
          // If it’s a non-null object, do a quick JSON.stringify
          else if (typeof val === "object" && val !== null) {
            return JSON.stringify(val, null, 2);
          } 
          // Otherwise, just coerce to string (numbers, strings, etc.)
          else {
            return String(val);
          }
        }

        var console = {
          log: function(...args) {
            // Convert each argument to a bracketed/JSON-like string
            var output = args.map(function(a) {
              return formatValue(a);
            }).join(" ");

            // Call the Swift bridging function
            _swiftConsoleLog(output);
          }
        };
        """#
        // Evaluate the above JS code in your context
        context.evaluateScript(consolePolyfill)
        
        let result = context.evaluateScript(jsCode)
        
        // Check if an exception occurred
        if let exception = context.exception {
            return "JS Error: \(exception.toString())"
        }
        
        if !consoleOutput.isEmpty {
            return consoleOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return result?.toString() ?? "No Output or undefined"
    }
}

struct OutputView: View {
    @Binding var outputText: String
    
    var body: some View {
        VStack {
            
            Capsule()
              .fill(Color.secondary)
              .frame(width: 40, height: 6)
              .padding(.top, 8)
            
            Text("JavaScript Output:")
                .font(.headline)
                .padding()
            
            TextEditor(text: $outputText)
                .border(Color.gray, width: 1)
                .padding()
                .frame(height: 300)
                .disabled(true)
            
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(JSFileDocument(text: "Preview code here")))
    }
}

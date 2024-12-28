//
//  JS_ScratchPadApp.swift
//  JS ScratchPad
//
//  Created by Jeremy Collins on 10/7/24.
//

import SwiftUI

@main
struct MyJSApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: JSFileDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}

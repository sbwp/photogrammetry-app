//
//  ObjectCaptureApp.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/17/22.
//

import SwiftUI

@main
struct ObjectCaptureApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: { ObjectCaptureProjectFile() }) { configuration in
            ObjectCaptureView()
        }
    }
}

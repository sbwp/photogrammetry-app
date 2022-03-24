//
//  PreviewView.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/17/22.
//

import SwiftUI
import AVKit

struct PreviewView: View {
    @EnvironmentObject var document: ObjectCaptureProjectFile
    @Binding var displayMode: DisplayMode
    var service: ObjectCaptureService
    
    var body: some View {
        VStack {
            Button("Upload \(document.project.images.count) images") {
                service.sendDepthImages(document.project.images)
                displayMode = .loading
            }
            .ocButtonStyle(.accentColor)
            ImageList()
            Button("Start Scan") {
                displayMode = .capture
            }
            .ocButtonStyle(.red)
        }
    }
}

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView(displayMode: .constant(.preview), service: ObjectCaptureService())
    }
}

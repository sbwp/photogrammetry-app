//
//  PreviewView.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/17/22.
//

import SwiftUI
import AVKit

struct PreviewView: View {
    @Binding var images: [AVCapturePhoto]
    @Binding var displayMode: DisplayMode
    
    var body: some View {
        VStack {
            Button("Upload \(images.count) images") {
                sendDepthImages(images)
            }
            ImageList(images: $images)
            Button("Rescan") {
                images = []
                displayMode = .capture
            }
        }
    }
}

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView(images: .constant([]), displayMode: .constant(.preview))
    }
}

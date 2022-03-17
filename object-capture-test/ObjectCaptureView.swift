//
//  ShazamKitView.swift
//  RCVisit
//
//  Created by Sabrina Bea on 3/15/22.
//

import SwiftUI
import AVKit

enum DisplayMode {
    case capture
    case preview
    case loading
    case results
}

struct ObjectCaptureView: View {
    @State var images: [AVCapturePhoto] = []
    @State var displayMode = DisplayMode.capture
    @State var timer: Timer? = nil
    
    var body: some View {
        switch displayMode {
        case .capture:
            CaptureView(images: $images, displayMode: $displayMode, timer: $timer)
        case .preview:
            PreviewView(images: $images, displayMode: $displayMode)
        case .loading:
            LoadingView(images: $images)
        case .results:
            ResultsView()
        }
    }
}



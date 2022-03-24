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
    @EnvironmentObject var file: ObjectCaptureProjectFile
    @Environment(\.undoManager) var undo
    @State var displayMode = DisplayMode.preview
    @State var timer: Timer? = nil
    let service = ObjectCaptureService()
    
    var body: some View {
        Group {
            switch displayMode {
            case .capture:
                CaptureView(displayMode: $displayMode, timer: $timer)
            case .preview:
                PreviewView(displayMode: $displayMode, service: service)
            case .loading:
                LoadingView(displayMode: $displayMode, service: service)
            case .results:
                ResultsView(displayMode: $displayMode, service: service)
            }
        }
        .onAppear() {
            displayMode = file.project.images.count > 0 ? .preview : .capture
        }
        .onDisappear() {
            undo?.registerUndo(withTarget: file) { _ in }
        }
    }
}



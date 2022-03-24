//
//  LoadingView.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/17/22.
//

import SwiftUI
import AVKit
import Combine

struct LoadingView: View {
    @State var percentage = 0
    @State var subs: [AnyCancellable] = []
    @State var error = ""
    @State var processingDone = false
    @Binding var displayMode: DisplayMode
    var service: ObjectCaptureService
    
    var progressMessage: String {
        if !error.isEmpty {
            return error
        }
        
        if processingDone {
            return "Processing Complete. Loading Image..."
        }
        
        if percentage == 0 {
            return "Uploading..."
        }
        
        return "Processing... \(percentage)%"
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Back") {
                    displayMode = .preview
                }
                .padding()
                Spacer()
            }
            Text(progressMessage)
                .font(.headline)
            if processingDone && !error.isEmpty {
                Button("Try Again") {
                    error = ""
                    service.getResult()
                }
                .ocButtonStyle(.accentColor)
            }
            ImageList()
        }
        .onAppear {
            subs.append(service.progress.sink(receiveValue: { percentage = $0 }))
            
            subs.append(service.complete.sink(receiveValue: {
                displayMode = .results
            }))
            
            subs.append(service.error.sink(receiveValue: {
                error = processingDone ? "Failed to load completed image. Try again?" : "Image Processing Failed :("
            }))
            
            subs.append(service.processingComplete.sink(receiveValue: {
                processingDone = true
            }))
        }
        .onDisappear() {
            for sub in subs {
                sub.cancel()
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(displayMode: .constant(.loading), service: ObjectCaptureService())
    }
}

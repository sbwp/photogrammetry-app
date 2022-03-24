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
        ZStack {
            ImageList(editable: false)
                .padding(.vertical, 50)
            
            VStack {
                BackButton {
                    displayMode = .preview
                }
                .padding(.leading)
                .padding(.top)
                .leftAlign()
                
                Text(progressMessage)
                    .padding(.bottom)
                    .font(.headline)
            }
            .blurredRow()
            .ceil()
            
            if !error.isEmpty {
                Button(action: {
                    error = ""
                    service.getResult()
                }) {
                    Label("Retry", systemImage: "repeat")
                        .fillRow()
                }
                .ocButtonStyle(.accentColor)
                .blurredRow()
                .floor()
            }
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
        .navigationBarHidden(true)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(displayMode: .constant(.loading), service: ObjectCaptureService())
            .preferredColorScheme(.dark)
            .environmentObject(ObjectCaptureProjectFile.preview)
    }
}

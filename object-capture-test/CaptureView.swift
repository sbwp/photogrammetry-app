//
//  CaptureView.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/17/22.
//

import SwiftUI
import AVKit

struct CaptureView: View {
    @State var isTakingNow = false
    @Binding var images: [AVCapturePhoto]
    @Binding var displayMode: DisplayMode
    @Binding var timer: Timer?
    
    let imageCaptureView = ImageCaptureView()
    
    var body: some View {
        VStack {
            Text("Images taken: \(images.count)")
            ZStack {
                imageCaptureView
                Rectangle() // Flash white overlay to simulate shutter or something (makes it feel like taking a photo rather than freezing, which is really what's happening)
                    .aspectRatio(0.75, contentMode: .fit)
                    .background(Color.white)
                    .opacity(isTakingNow ? 0.15 : 0)
            }
            if timer != nil {
                Button("Stop Scan") {
                    timer?.invalidate()
                    timer = nil
                    displayMode = .preview
                }
            } else {
                Button("Start Scan") {
                    // Not necessarily scientifically 1 second apart, but at least as good as me tapping with my hand every 1 second in Camera.app
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {_ in
                        Task {
                            isTakingNow = true
                            AudioServicesPlaySystemSound(1108); // Camera Sound
                            if let image = await imageCaptureView.takePicture() {
                                images.append(image)
                            }
                            isTakingNow = false
                        }
                    }
                    timer?.fire() // Start right now
                }
            }
            
        }
    }
}

struct CaptureView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureView(images: .constant([]), displayMode: .constant(.capture), timer: .constant(nil))
    }
}

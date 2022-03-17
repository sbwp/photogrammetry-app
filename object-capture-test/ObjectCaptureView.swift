//
//  ShazamKitView.swift
//  RCVisit
//
//  Created by Sabrina Bea on 3/15/22.
//

import SwiftUI
import AVKit

struct ObjectCaptureView: View {
    @State var image: AVCapturePhoto? = nil
    let imageCaptureView = ImageCaptureView()
    
    var body: some View {
        if let theImage = image {
            VStack {
                Image(uiImage: UIImage(cgImage: theImage.cgImageRepresentation()!))
                    .resizable()
                    .frame(width: 300, height: 240)
                Button("Back") {
                    image = nil
                }
            }
        } else {
            VStack {
                imageCaptureView
                Button("Snap") {
                    Task {
                        image = await imageCaptureView.takePicture()
                        print("picture taken: \(image != nil)")
                    }
                }
            }
        }
    }
}



//
//  CaptureView.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/17/22.
//

import SwiftUI
import AVKit

struct CaptureView: View {
    @EnvironmentObject var document: ObjectCaptureProjectFile
    @Environment(\.undoManager) var undo
    @State var isTakingNow = false
    @AppStorage("cameraType") var deviceType: AVCaptureDevice.DeviceType = .builtInLiDARDepthCamera
    @Binding var displayMode: DisplayMode
    @Binding var timer: Timer?
    
    var imageCaptureView: ImageCaptureView {
        ImageCaptureView(deviceType: $deviceType)
    }
    
    let supportedDeviceTypes: [AVCaptureDevice.DeviceType] = [
        .builtInLiDARDepthCamera,
        .builtInDualWideCamera,
        .builtInDualCamera,
        .builtInTrueDepthCamera
    ]
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    Text("LIDAR")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(deviceType == .builtInLiDARDepthCamera ? .primary : .secondary)
                    Image(systemName: "line.diagonal")
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .font(.system(size: 28))
                        .opacity(deviceType == .builtInLiDARDepthCamera ? 0 : 1)
                }
                Spacer()
                Text("\(document.project.images.count)")
                Spacer()
                Button("Preview") {
                    displayMode = .preview
                }
            }
            .padding(.horizontal)
            .padding(.top)
            ZStack {
                imageCaptureView
                Rectangle() // Flash white overlay to simulate shutter or something (makes it feel like taking a photo rather than freezing, which is really what's happening)
                    .aspectRatio(0.75, contentMode: .fit)
                    .background(Color.white)
                    .opacity(isTakingNow ? 0.15 : 0)
            }
            if timer != nil {
                Button(action: stopPhotos) {
                    Image(systemName: "stop.circle")
                        .foregroundColor(.red)
                        .font(.system(size: 48))
                }
            } else {
                HStack {
                    Button(action: repeatPhotos) {
                        Image(systemName: "repeat.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 48))
                    }
                    Spacer()
                    Button(action: takePhoto) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                            Circle()
                                .strokeBorder(Color.black, lineWidth: 3)
                            Circle()
                                .strokeBorder(Color.black, lineWidth: 4)
                                .padding(5)
                        }
                        .frame(width: 110, height: 110)
                    }
                    Spacer()
                    Button(action: changeCamera) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.system(size: 36))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func changeCamera() {
        deviceType = supportedDeviceTypes[
            (supportedDeviceTypes.firstIndex(of: deviceType)! + 1) %
            supportedDeviceTypes.count
        ]
    }
    
    private func repeatPhotos() {
        // Not necessarily scientifically timed, but at least as good as me tapping with my hand every N seconds in Camera.app
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) {_ in takePhoto()}
        timer?.fire() // Start right now
    }
    
    private func stopPhotos() {
        timer?.invalidate()
        timer = nil
        displayMode = .preview
    }
    
    private func takePhoto() {
        Task {
            // Really not the way to handle this, but this should help reduce double snaps when the timer gets behind and catches up
            if !isTakingNow {
                isTakingNow = true
//                AudioServicesPlaySystemSound(1108); // Camera Shutter Sound
                if let image = await imageCaptureView.takePicture(), let data = image.fileDataRepresentation() {
                    document.addImage(image: data)
                }
                isTakingNow = false
            }
        }
    }
}

struct CaptureView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureView(displayMode: .constant(.capture), timer: .constant(nil))
    }
}

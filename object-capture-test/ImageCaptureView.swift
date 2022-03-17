//
//  ImageCaptureView.swift
//  RCVisit
//
//  Created by Sabrina Bea on 3/17/22.
//

import SwiftUI
import AVKit

struct ImageCaptureView: UIViewRepresentable {
    let imageCaptureUIView = ImageCaptureUIView()

    func makeUIView(context: UIViewRepresentableContext<ImageCaptureView>) -> ImageCaptureUIView {
        ImageCaptureUIView()
    }

    func updateUIView(_ uiView: ImageCaptureUIView, context: UIViewRepresentableContext<ImageCaptureView>) {}

    func takePicture() async -> AVCapturePhoto? {
        return await imageCaptureUIView.takePhoto()
    }
}

struct ImageCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        ImageCaptureView()
    }
}

class ImageCaptureUIView: UIView {
    private var captureSession: AVCaptureSession!
    private var photoInput: AVCaptureDeviceInput!
    private var photoOutput: AVCapturePhotoOutput!
    
    init() {
        super.init(frame: .zero)
        
        if !hasAccessToCamera() {
            return
        }
        captureSession = AVCaptureSession()
        // Select a depth-capable capture device.
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
            for: .video, position: .unspecified)
            else { fatalError("No dual camera.") }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoDeviceInput)
            else { fatalError("Can't add video input.") }
        photoInput = videoDeviceInput
        captureSession.beginConfiguration()
        captureSession.addInput(photoInput)

        // Set up photo output for depth data capture.
        photoOutput = AVCapturePhotoOutput()
        photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
        guard captureSession.canAddOutput(photoOutput)
            else { fatalError("Can't add photo output.") }
        captureSession.addOutput(photoOutput)
        captureSession.sessionPreset = .photo
        captureSession.commitConfiguration()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func hasAccessToCamera() -> Bool {
        var result = false
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        AVCaptureDevice.requestAccess(for: .video) { allowed in
            result = allowed
            dispatchGroup.leave()
        }
        dispatchGroup.wait()

        return result
    }
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if self.superview != nil {
            print("START")
            self.videoPreviewLayer.session = self.captureSession
            self.videoPreviewLayer.videoGravity = .resizeAspect
            self.captureSession?.startRunning()
            print("STARTED")
        } else {
            print("STOP")
            self.captureSession?.stopRunning()
            print("STOPPED")
        }
    }
    
    func takePhoto() async -> AVCapturePhoto? {
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        photoSettings.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
        
        let captureProcessor = PhotoCaptureProcessor()
        
        
        await withCheckedContinuation({ (continuation: CheckedContinuation<Void, Never>) in
            captureProcessor.completion = { _ in
                continuation.resume()
            }
            self.captureSession?.startRunning()
            photoOutput.capturePhoto(with: photoSettings, delegate: captureProcessor)
        })
        
        
        return captureProcessor.photo;
    }
}
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
    @Binding var deviceType: AVCaptureDevice.DeviceType

    func makeUIView(context: UIViewRepresentableContext<ImageCaptureView>) -> ImageCaptureUIView {
        imageCaptureUIView.deviceType = deviceType
        return imageCaptureUIView
    }

    func updateUIView(_ uiView: ImageCaptureUIView, context: UIViewRepresentableContext<ImageCaptureView>) {
        imageCaptureUIView.deviceType = deviceType
    }

    func takePicture() async -> AVCapturePhoto? {
        return await imageCaptureUIView.takePhoto()
    }
}

struct ImageCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        ImageCaptureView(deviceType: .constant(.builtInLiDARDepthCamera))
    }
}

class ImageCaptureUIView: UIView {
    private var captureSession: AVCaptureSession!
    private var photoInput: AVCaptureDeviceInput!
    private var photoOutput: AVCapturePhotoOutput!
    private var _deviceType: AVCaptureDevice.DeviceType = .builtInLiDARDepthCamera
    
    public var deviceType: AVCaptureDevice.DeviceType {
        get {
            _deviceType
        }
        set(value) {
            if (value != _deviceType) {
                _deviceType = value
                changeCamera()
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        if !hasAccessToCamera() {
            fatalError("No Camera Access!")
        }
        
        captureSession = AVCaptureSession()
        // Select a depth-capable capture device.
        guard let videoDevice = AVCaptureDevice.default(deviceType, for: .video, position: .unspecified)
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
        print("F")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func changeCamera() {
        print("Changing camera from \(photoInput?.debugDescription ?? "nil") to \(deviceType.rawValue)")
        captureSession.beginConfiguration()
        
        for input in captureSession.inputs {
            captureSession.removeInput(input)
        }
        
        guard let videoDevice = AVCaptureDevice.default(deviceType, for: .video, position: .unspecified) else { fatalError("Camera not supported") }
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoDeviceInput)
            else { fatalError("Can't add video input.") }
        
        photoInput = videoDeviceInput
        captureSession.addInput(photoInput)
        captureSession.commitConfiguration()
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
        if self.superview != nil && !captureSession.isRunning {
            startCaptureSession()
        } else {
            self.captureSession?.stopRunning()
        }
        
    }
    
    private func startCaptureSession() {
        self.videoPreviewLayer.session = self.captureSession
        self.videoPreviewLayer.videoGravity = .resizeAspect
        photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
        
        print("S")
        self.captureSession?.startRunning()
    }
    
    func takePhoto() async -> AVCapturePhoto? {
        // Really frustrating bug, but this just randomly is false sometimes for no reason.
        // This lets it recheck before each photo to make sure the settings are compatible so we at least get a photo and don't crash.
        if photoOutput.isDepthDataDeliveryEnabled != photoOutput.isDepthDataDeliverySupported {
//            print(photoOutput.isDepthDataDeliverySupported)
            photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
        }
        
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        photoSettings.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
        
        let captureProcessor = PhotoCaptureProcessor()
        
        
        await withCheckedContinuation({ (continuation: CheckedContinuation<Void, Never>) in
            captureProcessor.completion = { _ in
                continuation.resume()
            }
            if !self.captureSession.isRunning {
//                print("Start Running")
                startCaptureSession()
//                self.captureSession?.startRunning() // Don't care enough to fix it. For some reason this is getting stopped, so we'll just restart it in that case
            }
            photoOutput.capturePhoto(with: photoSettings, delegate: captureProcessor)
        })
        if !self.captureSession.isRunning {
            self.captureSession?.startRunning() // Don't care enough to fix it. For some reason this is getting stopped, so we'll just restart it in that case
        }
        
        return captureProcessor.photo;
    }
}

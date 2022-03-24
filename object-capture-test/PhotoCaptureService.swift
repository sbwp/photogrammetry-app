//
//  PhotoCaptureService.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/23/22.
//

import AVFoundation

// Note: I think this is a really bad way to do this. I'm pretty sure this object will just be hanging around forever, possibly consuming resources (at least the captureSession should be ended)
class PhotoCaptureService {
    public var captureSession: AVCaptureSession!
    private var photoInput: AVCaptureDeviceInput!
    private var photoOutput: AVCapturePhotoOutput!
    private var _deviceType: AVCaptureDevice.DeviceType = .builtInLiDARDepthCamera
    
    public var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    private static var _instance: PhotoCaptureService? = nil
    public static var instance: PhotoCaptureService {
        _instance = _instance ?? PhotoCaptureService()
        return _instance!
    }
    
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
    }
    
    private func changeCamera() {
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
    
    public func startCaptureSession() {
        videoPreviewLayer.session = self.captureSession
        videoPreviewLayer.videoGravity = .resizeAspect
        photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
        
        captureSession?.startRunning()
    }
    
    func takePhoto() async -> AVCapturePhoto? {
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        photoSettings.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
        
        let captureProcessor = PhotoCaptureProcessor()
        
        
        await withCheckedContinuation({ (continuation: CheckedContinuation<Void, Never>) in
            captureProcessor.completion = { _ in
                continuation.resume()
            }
            photoOutput.capturePhoto(with: photoSettings, delegate: captureProcessor)
        })
        
        return captureProcessor.photo;
    }
}

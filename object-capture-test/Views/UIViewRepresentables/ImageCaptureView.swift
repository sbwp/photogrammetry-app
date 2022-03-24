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
    private var captureService: PhotoCaptureService
    
    public var deviceType: AVCaptureDevice.DeviceType {
        get {
            captureService.deviceType
        }
        set(value) {
            captureService.deviceType = value
        }
    }
    
    init() {
        captureService = PhotoCaptureService.instance
        super.init(frame: .zero)
        captureService.videoPreviewLayer = videoPreviewLayer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview != nil && !captureService.captureSession.isRunning {
            captureService.startCaptureSession()
        } else {
            captureService.captureSession?.stopRunning()
        }
        
    }
    
    func takePhoto() async -> AVCapturePhoto? {
        return await captureService.takePhoto()
    }
}

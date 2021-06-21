//
//  CaptureSessionManager.swift
//  AVCaptureSession
//
//  Created by 柳钰柯 on 2021/6/18.
//

import Foundation
import AVFoundation

class CaptureSessionManager {
    enum Resolution {
        case w3840xh2160
        case w1920xh1080
        case w1280xh720
        case w640xh480
        
        var width: Int32 {
            switch self {
            case .w640xh480:
                return 640
            case .w1920xh1080:
                return 1920
            case .w3840xh2160:
                return 3840
            case .w1280xh720:
                return 1280
            }
        }
        
        var height: Int32 {
            switch self {
            case .w640xh480:
                return 480
            case .w1920xh1080:
                return 1080
            case .w3840xh2160:
                return 2160
            case .w1280xh720:
                return 720
            }
        }
        
    }
    private(set) var session: AVCaptureSession
    
    init() {
        session = AVCaptureSession()
        session.sessionPreset = .photo
        NotificationCenter.default.addObserver(self, selector: #selector(avCaptureSessionRuntimeErrorNotification(_:)), name: Notification.Name.AVCaptureSessionRuntimeError, object: nil)
        if let device = AVCaptureDevice.default(for: .video), let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) {
            currentDevice = device
            session.addInput(input)
            let output = AVCapturePhotoOutput()
            session.addOutput(output)
            currentInput = input
            currentPhotoOutput = output
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.alwaysDiscardsLateVideoFrames = true
            session.addOutput(videoOutput)
            currentVideoOutput = videoOutput
            session.beginConfiguration()
            do {
                try device.lockForConfiguration()
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    device.focusMode = .continuousAutoFocus
                }
                if device.isExposureModeSupported(.continuousAutoExposure) {
                    device.exposureMode = .continuousAutoExposure
                }
                device.unlockForConfiguration()
            } catch {
                print("lockForConfiguration 失败")
            }
            session.commitConfiguration()
        }
    }
    
    func start() {
        if session.inputs.isEmpty { return }
        currentVideoOutput?.connection(with: .video)?.videoOrientation = .portrait
        currentPhotoOutput?.connection(with: .video)?.videoOrientation = .portrait
        session.startRunning()
    }
    
    func stop() {
        session.stopRunning()
    }
    
    func shot(with settings: AVCapturePhotoSettings, delegate: AVCapturePhotoCaptureDelegate) {
        currentPhotoOutput?.capturePhoto(with: settings, delegate: delegate)
    }
    
    func startRecord(delegate: AVCaptureVideoDataOutputSampleBufferDelegate,queue: DispatchQueue?) {
        currentVideoOutput?.setSampleBufferDelegate(delegate, queue: queue)
    }
    
    func stopRecord() {
        currentVideoOutput?.setSampleBufferDelegate(nil, queue: nil)
    }
    
    func setCameraPosition(_ position: AVCaptureDevice.Position) {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        do {
            let discoverSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera,.builtInWideAngleCamera], mediaType: .video, position: position)
            guard let device = discoverSession.devices.first(where: { $0.position == position }) else { return }
            try device.lockForConfiguration()
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            let input = try AVCaptureDeviceInput(device: device)
            if currentInput != nil {
                session.removeInput(currentInput!)
            }
            if session.canAddInput(input) {
                session.addInput(input)
                currentInput = input
            }
            currentVideoOutput?.connection(with: .video)?.videoOrientation = .portrait
            if position == .front {
                currentPhotoOutput?.connection(with: .video)?.isVideoMirrored = true
                currentVideoOutput?.connection(with: .video)?.isVideoMirrored = true
            } else {
                currentPhotoOutput?.connection(with: .video)?.isVideoMirrored = false
                currentVideoOutput?.connection(with: .video)?.isVideoMirrored = false
            }
            device.unlockForConfiguration()
            currentDevice = device
        } catch {
            print(error)
        }
    }
    
    func setCameraFrameRate(_ frameRata: Int32, resolution: Resolution, position: AVCaptureDevice.Position, videoFormat: CMFormatDescription.MediaSubType = .h264) throws {
        let discoverSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera,.builtInDualCamera,.builtInDualWideCamera,.builtInTrueDepthCamera], mediaType: .video, position: position)
        guard let device = discoverSession.devices.first(where: { $0.position == position }) else { return }
        currentDevice = device
        for format in device.formats {
            let description = format.formatDescription
            guard let _ = format.videoSupportedFrameRateRanges.first(where: { $0.maxFrameRate >= Float64(frameRata)}), description.mediaSubType == videoFormat else {
                continue
            }
            let dims = description.dimensions
            guard dims.height == resolution.height && dims.width == resolution.width else {continue}
            session.beginConfiguration()
            try device.lockForConfiguration()
            device.activeFormat = format
            device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: frameRata)
            device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: frameRata)
            device.unlockForConfiguration()
            let input = try AVCaptureDeviceInput(device: device)
            if currentInput != nil {
                session.removeInput(currentInput!)
            }
            if session.canAddInput(input) {
                session.addInput(input)
                currentInput = input
            }
            let photoOutput = AVCapturePhotoOutput()
            if currentPhotoOutput != nil {
                session.removeOutput(currentPhotoOutput!)
            }
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
                currentPhotoOutput = photoOutput
            } else {
                print("无法添加PhotoOutput")
            }
            let videoOutput = AVCaptureVideoDataOutput()
            if currentVideoOutput != nil {
                session.removeOutput(currentVideoOutput!)
            }
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
                currentVideoOutput = videoOutput
            } else {
                print("无法添加VideoOutput")
            }
            
            
            session.commitConfiguration()
        }
    }
    private var currentDevice: AVCaptureDevice?
    private var currentInput: AVCaptureInput?
    private var currentPhotoOutput: AVCapturePhotoOutput?
    private var currentVideoOutput: AVCaptureVideoDataOutput?
}

// MARK: - private
private extension CaptureSessionManager {
    @objc func avCaptureSessionRuntimeErrorNotification(_ sender: Notification) {
        guard let info = sender.userInfo else { return }
        print(info)
    }
}

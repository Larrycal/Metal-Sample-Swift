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
        if let device = AVCaptureDevice.default(for: .video), let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) {
            session.addInput(input)
            let output = AVCapturePhotoOutput()
            session.addOutput(output)
            currentInput = input
            currentOutput = output
        }
    }
    
    func start() {
        if session.inputs.isEmpty { return }
        session.startRunning()
    }
    
    func stop() {
        session.stopRunning()
    }
    
    func shot(with settings: AVCapturePhotoSettings, delegate: AVCapturePhotoCaptureDelegate) {
        (currentOutput as? AVCapturePhotoOutput)?.capturePhoto(with: settings, delegate: delegate)
    }
    
    func setCameraFrameRate(_ frameRata: Int32, resolution: Resolution, position: AVCaptureDevice.Position, videoFormat: CMFormatDescription.MediaSubType = .h264) throws {
        let discoverSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera,.builtInDualCamera,.builtInDualWideCamera,.builtInTrueDepthCamera], mediaType: .video, position: position)
        guard let device = discoverSession.devices.first(where: { $0.position == position }) else { return }
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
            if session.canAddInput(input) {
                if currentInput != nil {
                    session.removeInput(currentInput!)
                }
                session.addInput(input)
                currentInput = input
            }
            let output = AVCapturePhotoOutput()
            if session.canAddOutput(output) {
                if currentOutput != nil {
                    session.removeOutput(currentOutput!)
                }
                session.addOutput(output)
                currentOutput = output
            }
            
            session.commitConfiguration()
        }
    }
    private var currentInput: AVCaptureInput?
    private var currentOutput: AVCaptureOutput?
}

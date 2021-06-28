//
//  ViewController.swift
//  AVCaptureSession
//
//  Created by 柳钰柯 on 2021/6/18.
//

import UIKit
import Utility
import SnapKit
import AVFoundation
import Photos
import AVKit
import CoreMedia

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        func addAndStartVideoView() {
            renderer = MetalRenderer(view: capturePreviewView)
            capturePreviewView.delegate = renderer
            if let device = capturePreviewView.device {
                CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)
            }
            view.addSubview(capturePreviewView)
            view.addSubview(previewImageView)
            capturePreviewView.addSubview(effectiveView)
            view.addSubview(exchangeCameraButton)
            capturePreviewView.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: Constants.screenWidth, height: Constants.screenHeight*2/3))
                make.top.left.equalTo(0)
            }
            previewImageView.snp.makeConstraints { make in
                make.left.equalTo(16)
                make.bottom.equalTo(-16-Constants.indicatorSafeHeight)
                make.size.equalTo(CGSize(width: 50, height: 50 * Constants.screenHeight / (Constants.screenWidth * 1.5 )))
            }
            effectiveView.snp.makeConstraints { make in
                make.edges.equalTo(capturePreviewView)
            }
            exchangeCameraButton.snp.makeConstraints { make in
                make.right.equalTo(-8)
                make.top.equalTo(capturePreviewView.snp.bottom).offset(8)
            }
            sessionManager.start()
            sessionManager.dataOutputSet(delegate: self, queue: recordingQueue)
        }
        view.backgroundColor = .white
        view.addSubview(shotButton)
        
        shotButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-61-Constants.indicatorSafeHeight)
            make.size.equalTo(88)
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            addAndStartVideoView()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if granted {
                    DispatchQueue.main.async {
                        addAndStartVideoView()
                    }
                }
            })
        case .denied,.restricted:
            print("无相机权限")
        @unknown default:
            print("未知状态")
        }
    }

    private lazy var sessionManager: CaptureSessionManager = {
        let temp = CaptureSessionManager()
        return temp
    }()
    
    private lazy var capturePreviewView: MetalCaptureVideoView = {
        let temp = MetalCaptureVideoView()
//        temp.videoPreviewLayer.session = sessionManager.session
//        temp.videoPreviewLayer.videoGravity = .resizeAspectFill
        return temp
    }()
    
    private lazy var effectiveView: UIVisualEffectView = {
        let temp = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        temp.isHidden = true
        return temp
    }()
    
    private lazy var shotButton: UIButton = {
        let temp = UIButton()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(recordHandler(_:)))
        temp.addGestureRecognizer(longPress)
        temp.setBackgroundImage(UIImage(named: "camera_shot_btn"), for: .normal)
        temp.addTarget(self, action: #selector(shotButtonClick), for: .touchUpInside)
        return temp
    }()
    
    private lazy var exchangeCameraButton: UIButton = {
        let temp = UIButton()
        temp.setImage(UIImage(named: "camera_exchange_btn"), for: .normal)
        temp.addTarget(self, action: #selector(cameraChangeClick), for: .touchUpInside)
        return temp
    }()
    
    private lazy var previewImageView: UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .scaleAspectFill
        temp.isHidden = true
        return temp
    }()
    
    private lazy var recordingQueue: DispatchQueue = {
        let temp = DispatchQueue(label: "com.larry.AVCaptureSession.recordingQueue",qos: .userInteractive)
        return temp
    }()
    
    private var writer:ReaderWriter?
    private var sessionAtSourceTime: CMTime?
    private var renderer: MetalRenderer?
    private var textureCache: CVMetalTextureCache?
//    private var texture: CVMetalTexture?
    private var copiedSampleBuffer: CMSampleBuffer?
    private var lock: NSRecursiveLock = NSRecursiveLock()
    private var _isRecording: Bool = false
}

private extension ViewController {
    func animateShowPreview() {
        let toFrame = previewImageView.frame
        let fromFrame = capturePreviewView.frame
        previewImageView.frame = fromFrame
        setPreviewImageFromState()
        UIView.transition(with: previewImageView, duration: 0.5, options: .curveEaseInOut, animations: {
            self.previewImageView.frame = toFrame
            self.setPreviewImageToState()
        }, completion: nil)
    }
    
    func setPreviewImageFromState() {
        if previewImageView.isHidden {
            previewImageView.isHidden = false
        }
        previewImageView.layer.cornerRadius = 0
        previewImageView.layer.borderWidth = 0
    }
    
    func setPreviewImageToState() {
        previewImageView.layer.cornerRadius = 8
        previewImageView.layer.masksToBounds = true
        previewImageView.layer.borderWidth = Constants.onePixel
        previewImageView.layer.borderColor = UIColor(hexValue: 0xD3D3D3).cgColor
    }
    
    
    // MARK: - action
    @objc func shotButtonClick() {
        print("shot 事件触发")
        var config = WriterConfigration(outputURL: URL(fileURLWithPath: Constants.userTempDirectoryPath + "test.mp4"))
        var settings = config.settings
        settings[AVVideoWidthKey] = capturePreviewView.frame.width * UIScreen.main.scale
        settings[AVVideoHeightKey] = capturePreviewView.frame.height * UIScreen.main.scale
        config.settings = settings
        PHPhotoLibrary.requestAuthorization({ status in
            guard status == .authorized else { return }
            DispatchQueue.main.async {
                self.shotButton.isEnabled = false
                let setting = AVCapturePhotoSettings()
                let pbpf = setting.availablePreviewPhotoPixelFormatTypes[0]
                setting.previewPhotoFormat = [
                    kCVPixelBufferPixelFormatTypeKey as String: pbpf,
                    kCVPixelBufferWidthKey as String: self.capturePreviewView.frame.width * UIScreen.main.scale,
                    kCVPixelBufferHeightKey as String: self.capturePreviewView.frame.height * UIScreen.main.scale
                ]
                self.sessionManager.shot(with: AVCapturePhotoSettings(), delegate: self)
            }
        })
    }
    
    @objc func cameraChangeClick() {
        exchangeCameraButton.isSelected = !exchangeCameraButton.isSelected
        effectiveView.isHidden = false
        UIView.transition(with: capturePreviewView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
        }, completion: { _ in
            self.capturePreviewView.alpha = 0
            self.sessionManager.setCameraPosition(self.exchangeCameraButton.isSelected ? .front : .back)
            UIView.animate(withDuration: 0.2) {
                self.capturePreviewView.alpha = 1
            }
            self.effectiveView.isHidden = true
        })
    }
    
    @objc func recordHandler(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            _isRecording = true
            shotButton.isHighlighted = true
            var config = WriterConfigration(outputURL: URL(fileURLWithPath: Constants.userTempDirectoryPath + "test.mp4"))
            var settings = config.settings
            settings[AVVideoWidthKey] = capturePreviewView.frame.width * UIScreen.main.scale
            settings[AVVideoHeightKey] = capturePreviewView.frame.height * UIScreen.main.scale
            config.settings = settings
            writer = try? ReaderWriter(writerConfigration: config)
            if writer?.start() == true {
                print("start recording")
            }
        case .changed,.possible:
            shotButton.isHighlighted = true
        case .cancelled,.ended,.failed:
            print("finish")
            _isRecording = false
            shotButton.isHighlighted = false
            writer?.videoWriterInput.markAsFinished()
            writer?.finish() {
                self.sessionAtSourceTime = nil
                self.writer = nil
                PHPhotoLibrary.shared().performChanges({
                    let change = PHAssetCreationRequest.forAsset()
                    change.addResource(with: .video, fileURL: URL(fileURLWithPath: Constants.userTempDirectoryPath + "test.mp4"), options: nil)
                }, completionHandler: nil)
            }
        @unknown default:
            break
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        shotButton.isEnabled = true
        if let data = photo.fileDataRepresentation() {
            PHPhotoLibrary.shared().performChanges {
                let change = PHAssetCreationRequest.forAsset()
                change.addResource(with: .photo, data: data, options: nil)
            } completionHandler: { _, _ in
                
            }
            previewImageView.image = UIImage(data: data)
            animateShowPreview()
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        if _isRecording {
//            guard writer?.isStartWritting == true else { return }
//            if sessionAtSourceTime == nil {
//                sessionAtSourceTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
//                writer?.assetWriter.startSession(atSourceTime: sessionAtSourceTime!)
//            }
//            if output is AVCaptureVideoDataOutput, writer?.videoWriterInput.isReadyForMoreMediaData == true {
//                let error = writer?.record(sampleBuffer)
//                if error != nil {
//                    print(error!)
//                }
//            }
//        }
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer), let textureCache = textureCache else { return }
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        var texture: CVMetalTexture?
        guard CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, imageBuffer, nil, .bgra8Unorm, width, height, 0, &texture) == kCVReturnSuccess, texture != nil, let metalTexture = CVMetalTextureGetTexture(texture!) else { return }
        renderer?.texture = metalTexture
        CVMetalTextureCacheFlush(textureCache, 0)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let att = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: false) {
            print(att)
        }
    }
}

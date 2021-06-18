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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        func addAndStartVideoView() {
            view.addSubview(capturePreviewView)
            view.addSubview(previewImageView)
            capturePreviewView.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: Constants.screenWidth, height: Constants.screenHeight*2/3))
                make.top.left.equalTo(0)
            }
            previewImageView.snp.makeConstraints { make in
                make.edges.equalTo(capturePreviewView)
            }
            sessionManager.start()
        }
        view.backgroundColor = .white
        view.addSubview(shotButton)
        
        shotButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(Constants.screenHeight*5/6)
            make.size.equalTo(66)
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
    
    private lazy var capturePreviewView: AVCaptureVideoPreviewView = {
        let temp = AVCaptureVideoPreviewView()
        temp.videoPreviewLayer.session = sessionManager.session
        temp.videoPreviewLayer.videoGravity = .resizeAspectFill
        return temp
    }()
    
    private lazy var shotButton: UIButton = {
        let temp = UIButton()
        temp.backgroundColor = Colors.Nord.nord11
        temp.layer.cornerRadius = 33
        temp.layer.masksToBounds = true
        temp.addTarget(self, action: #selector(shotButtonClick), for: .touchUpInside)
        return temp
    }()
    
    private lazy var previewImageView: UIImageView = {
        let temp = UIImageView()
        temp.backgroundColor = .white
        temp.alpha = 0
        return temp
    }()
}

extension ViewController {
    @objc func shotButtonClick() {
        PHPhotoLibrary.requestAuthorization({ status in
            guard status == .authorized else { return }
            DispatchQueue.main.async {
                self.shotButton.isEnabled = false
                self.sessionManager.shot(with: AVCapturePhotoSettings(), delegate: self)
            }
        })
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            UIView.transition(with: previewImageView, duration: 0.5, options: .curveEaseInOut, animations: {
                self.previewImageView.alpha = 1
                self.previewImageView.image = image
            }, completion: nil)
        }
    }
}

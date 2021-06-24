//
//  MetalCaptureVideoView.swift
//  AVCaptureSession
//
//  Created by 柳钰柯 on 2021/6/24.
//

import UIKit
import Metal
import MetalKit
import Utility

protocol MetalCaptureVideoViewDelegate: AnyObject {
    func draw(in view: MetalCaptureVideoView)
}

class MetalCaptureVideoView: UIView {
    var preferredFramePerSeconds: Int = 30
    var clearColor: UIColor = .white
    var pixelFormat: MTLPixelFormat = .bgra8Unorm
    var currentDrawable: CAMetalDrawable?
    var frameDuration: TimeInterval = 0
    var delegate: MetalCaptureVideoViewDelegate?
    let device: MTLDevice?
    
    var contentsGravity: CALayerContentsGravity {
        get {
            return metalLayer.contentsGravity
        }
        set {
            metalLayer.contentsGravity = .resizeAspectFill
        }
    }
    
    var metalLayer: CAMetalLayer {
        return layer as! CAMetalLayer
    }
    
    var currentRenderPassDescriptor: MTLRenderPassDescriptor? {
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = currentDrawable?.texture
        descriptor.colorAttachments[0].clearColor = clearColor.metalColor
        descriptor.colorAttachments[0].storeAction = .store
        descriptor.colorAttachments[0].loadAction = .clear
        return descriptor
    }
    
    override init(frame: CGRect = .zero) {
        device = MTLCreateSystemDefaultDevice()
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        device = MTLCreateSystemDefaultDevice()
        super.init(coder: coder)
        setup()
    }
    
    override class var layerClass: AnyClass {
        return CAMetalLayer.self
    }
    
    override func didMoveToWindow() {
        if window == nil {
            displayLink?.invalidate()
            displayLink = nil
        } else {
            displayLink?.invalidate()
            displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidFire(_:)))
            displayLink?.preferredFramesPerSecond = preferredFramePerSeconds
            displayLink?.add(to: RunLoop.main, forMode: .common)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let drawableSize = CGSize(width: bounds.width * Constants.screenScale, height: bounds.height * Constants.screenScale)
        metalLayer.drawableSize = drawableSize
    }
    
    
    
    private var displayLink: CADisplayLink?

}

private extension MetalCaptureVideoView {
    func setup() {
        metalLayer.pixelFormat = pixelFormat
        metalLayer.contentsGravity = .resizeAspectFill
    }
    
    @objc func displayLinkDidFire(_ displayLink: CADisplayLink) {
        currentDrawable = metalLayer.nextDrawable()
        frameDuration = displayLink.duration
        delegate?.draw(in: self)
    }
}

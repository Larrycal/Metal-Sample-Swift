//
//  ViewController.swift
//  MetalDevelop
//
//  Created by 柳钰柯 on 2021/6/21.
//

import UIKit
import Metal
import MetalKit
import SnapKit
import Utility

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupMetal()
        view.addSubview(mtkView)
        mtkView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    private var adder: MetalAdder?
    
    private lazy var mtkView: MTKView = {
        let temp = MTKView()
        temp.depthStencilPixelFormat = .depth32Float
        temp.clearDepth = 1.0
        return temp
    }()
    
    private var renderer: Renderer?
}

private extension ViewController {
    func setupMetal() {
        guard let device = MTLCreateSystemDefaultDevice() else { print("创建MTLDevice失败");return }
        mtkView.device = device
        renderer = Renderer(with: mtkView)
        mtkView.delegate = renderer
//        mtkView.enableSetNeedsDisplay = true
        mtkView.clearColor = Colors.Nord.nord8.metalColor
    }
}


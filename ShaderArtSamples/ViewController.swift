//
//  ViewController.swift
//  ShaderArtSamples
//
//  Created by TakatsuYouichi on 2019/07/07.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

import UIKit
import MetalKit
import AVFoundation
import CoreMotion
class ViewController: UIViewController {

    @IBOutlet weak var metalView: MTKView!
    
    var gpu: GPUDevice!
    var fragmentShader: MTLFunction!
    
    // Pipeline
    var commandQueue : MTLCommandQueue! = nil
    var pipelineState : MTLRenderPipelineState! = nil

    // Acceleration Sensor
    let motionManager = CMMotionManager()
    
    // Textures
    var imageTexture : MTLTexture! = nil

    // Start Date
    let startDate = Date()

    // Audio
    var volumeLevel : Float = 0.0
    
    // Acceleration
    var acceleration = Acceleration(x:0.0, y:0.0, z:0.0)
    
    // CaptureTexture
    private var cameraTexture : MTLTexture? = nil
    
    // semaphore
    private let semaphore = DispatchSemaphore(value: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Prepare for Metal
        gpu = GPUDevice.shared
        metalView.device = gpu.device
        metalView.delegate = self

        commandQueue = gpu.device.makeCommandQueue()
        
        let textureLoader = MTKTextureLoader(device:gpu.device)
        self.imageTexture = try! textureLoader.newTexture(name: "icon", scaleFactor: 0.0, bundle: nil, options: nil)
        
        // Create Pipiline
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = GPUDevice.shared.vertexFunction

        pipelineStateDescriptor.fragmentFunction = fragmentShader
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! gpu.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        // Setup Video
        VideoSession.shared.videoOrientation = .landscapeRight
        VideoSession.shared.delegate = self

        // 加速度センサー
        self.motionManager.accelerometerUpdateInterval = 1.0/60.0
        self.motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { [weak `self`](motion, error) in
            guard let motion = motion, let `self` = self else { return }
            self.acceleration.x = Float(motion.gravity.x)
            self.acceleration.y = Float(motion.gravity.y)
            self.acceleration.z = Float(motion.gravity.z)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        VideoSession.shared.startSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        VideoSession.shared.endSession()
    }

    @IBAction func close(_ sender: Any) {
        VideoSession.shared.endSession()
        self.dismiss(animated: true, completion: nil)
    }
}

extension ViewController : SessionDelegate {
    func session(_ session: VideoSession, didReceiveVideoTexture texture: MTLTexture) {
        cameraTexture = texture
    }
    
    func session(_ session: VideoSession, didReceiveAudioVolume volume: Float) {
        volumeLevel = volume
    }
}

extension ViewController : MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        gpu.updateResolution(width: Float(size.width), height: Float(size.height))
    }
    
    func draw(in view: MTKView) {
        _ = semaphore.wait(timeout: .distantFuture)
        guard
            let renderPassDesicriptor = metalView.currentRenderPassDescriptor,
            let currentDrawable = metalView.currentDrawable,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let cameraTexture = self.cameraTexture,
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDesicriptor) else {
                semaphore.signal()
                return
        }
        gpu.updateTime(Float(Date().timeIntervalSince(startDate)))
        gpu.updateVolume(volumeLevel)
        gpu.updateAcceleration(acceleration)

        renderEncoder.setRenderPipelineState(pipelineState)

        renderEncoder.setFragmentBuffer(gpu.resolutionBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentBuffer(gpu.timeBuffer, offset: 0, index: 1)
        renderEncoder.setFragmentBuffer(gpu.volumeBuffer, offset: 0, index: 2)
        renderEncoder.setFragmentBuffer(gpu.accelerationBuffer, offset: 0, index: 3)

        renderEncoder.setFragmentTexture(imageTexture, index: 0)
        renderEncoder.setFragmentTexture(cameraTexture, index: 1)
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        
        commandBuffer.addScheduledHandler { [weak self] (buffer) in
            guard let self = self else { return }
            self.semaphore.signal()
        }
        
        // commit
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
}

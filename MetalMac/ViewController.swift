//
//  ViewController.swift
//  MetalMac
//
//  Created by Scott Richards on 3/18/22.
//

import Cocoa
import Metal
import MetalKit

class ViewController: NSViewController {
    let vertexData:[Float] =
    [0.0, 1.0, 0.0,
     -1.0, -1.0, 0.0,
     1.0, -1.0, 0.0]
    
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
//    var timer: CADisplayLink!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        // CVDisplayLink attempt
//        let displayID = CGMainDisplayID()
//        var error: CVReturn?
//        error = CVDisplayLinkCreateWithCGDisplay(displayID, &displayLink);
//        if error != nil
//        {
//            print("DisplayLink created with error: \(error)");
//            displayLink = NULL;
//        }
//        CVDisplayLinkSetOutputCallback(displayLink, renderCallback, (__bridge void *)self);
        
//        timer = CADisplayLink(target: self, selector: #selector(gameloop))
//        timer.add(to: RunLoop.main, forMode: .default)
    }
    
    override func viewDidAppear() {
        setupMetal()
    }
    
    func setupMetal() {
        device = MTLCreateSystemDefaultDevice()
        self.view.wantsLayer = true
        metalLayer = CAMetalLayer()          // 1
        metalLayer.device = device           // 2
        metalLayer.pixelFormat = .bgra8Unorm // 3
        metalLayer.framebufferOnly = true    // 4
        if let frame = view.layer?.frame {
            metalLayer.frame = frame // 5
        }
        if let layer = view.layer {
            layer.addSublayer(metalLayer)   // 6
        }
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0]) // 1
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: []) // 2
        
        // 1
        guard  let defaultLibrary = device.makeDefaultLibrary() else {
            return
        }
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")

        // 2
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // 3
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue()
  
        Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(gameloop), userInfo: nil, repeats: true)
    }
    
    func render() {
        guard let drawable = metalLayer?.nextDrawable() else { return }
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        //    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 255.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    @objc func gameloop() {
        autoreleasepool {
            self.render()
        }
    }
    //
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //
    //        // Do any additional setup after loading the view.
    //    }
    //
    //    override var representedObject: Any? {
    //        didSet {
    //        // Update the view, if already loaded.
    //        }
    //    }
    //
    
}


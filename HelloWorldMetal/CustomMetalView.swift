//
//  CustomMetalView.swift
//  HelloWorldMetal
//
//  Created by Mladen Mikic on 15/07/2020.
//

import Foundation
import Metal
import Cocoa


class CustomMetalView: NSView,
                       // https://developer.apple.com/documentation/quartzcore/calayerdelegate
                       CALayerDelegate {
    
    // https://developer.apple.com/documentation/quartzcore/cametallayer
    private var metalLayer: CAMetalLayer! = nil
    
    // MARK: - Init
    
    override public init(frame:NSRect) {
        super.init(frame:frame)
        self.commonInit()
    }
    
    required public init?(coder:NSCoder) {
        super.init(coder:coder)
        self.commonInit()
    }
    
    open func commonInit() {
        self.wantsLayer = true
        self.layerContentsRedrawPolicy = .duringViewResize
    }
    
    // MARK: - View methods
    
    // https://developer.apple.com/documentation/appkit/nsview/1483687-makebackinglayer
    override func makeBackingLayer() -> CALayer {
        // https://developer.apple.com/documentation/quartzcore/cametallayer
        let layer = CAMetalLayer()
        layer.pixelFormat = .bgra8Unorm
        layer.delegate = self
        self.metalLayer = layer
        return layer
    }
    
    //  https://developer.apple.com/documentation/appkit/nsview/1483329-viewdidmovetowindow
    override func viewDidMoveToWindow() {
        self.reDraw()
    }
    
    // MARK: - Helpers
    
    // https://developer.apple.com/documentation/metal/mtldevice
    func assignDevice(_ device: MTLDevice) {
        self.metalLayer.device = device
        print("\nDevice \(device.name) has been set to: \(self).")
    }
    
    func reDraw() {
        
        // https://developer.apple.com/documentation/metal/mtlcommandqueue
        guard let commandQueue = self.metalLayer.device?.makeCommandQueue() else { return }
        // https://developer.apple.com/documentation/quartzcore/cametaldrawable
        guard let drawable = self.metalLayer.nextDrawable() else { return }
        
        // https://developer.apple.com/documentation/metal/mtltexture
        let texture = drawable.texture
        
        // https://developer.apple.com/documentation/metal/mtlrenderpassdescriptor
        let passDescriptor = MTLRenderPassDescriptor()
        
        // https://developer.apple.com/documentation/metal/mtlrenderpasscolorattachmentdescriptor
        let colorAttachment = passDescriptor.colorAttachments[0]
        colorAttachment?.texture = texture
        colorAttachment?.loadAction = .clear
        colorAttachment?.storeAction = .store
        colorAttachment?.clearColor = MTLClearColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        // https://developer.apple.com/documentation/metal/mtlcommandbuffer
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        // https://developer.apple.com/documentation/metal/mtlrendercommandencoder
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: passDescriptor)
        commandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

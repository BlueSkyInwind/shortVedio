//
//  YXBaseRecordManager.swift
//  ShortVideoRecording
//
//  Created by admin on 2017/12/6.
//  Copyright © 2017年 WangYongxin. All rights reserved.
//

import UIKit
import AVFoundation

class YXBaseRecordManager: NSObject{
    
    lazy var captureSession : AVCaptureSession = {
        let captureSession = AVCaptureSession.init()
        captureSession.beginConfiguration()
        return captureSession
    }()
    
    lazy var  captureDevice : AVCaptureDevice = {
        var device : AVCaptureDevice?
        var captureDevices : NSArray
        if #available(iOS 10, *){
            captureDevices = AVCaptureDevice.devices(for: AVMediaType.video) as NSArray
        }else{
            let devicesIOS10 = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.front)
            captureDevices = devicesIOS10.devices as NSArray
        }
        for  devices in captureDevices {
            if (devices as! AVCaptureDevice).position == .front{
                device = (devices as! AVCaptureDevice)
            }
        }
        return device!
    }()
    
    lazy var queue : DispatchQueue = {
       let queue = DispatchQueue.init(label: "www.captureQue.com")
        return queue
    }()
    
    lazy var videoDataOutput : AVCaptureMovieFileOutput = {
        let  videoDataOutput  = AVCaptureMovieFileOutput.init()
        return videoDataOutput
    }()

    var activeVideoInput : AVCaptureDeviceInput?
    
    override init() {
        super.init()
        
    }
    
    func startSession()  {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }

    func stopSession()  {
        if captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    func activeDeviceConfigure(device : AVCaptureDevice)  {
        
        do{
           try device.lockForConfiguration()
        }catch{
            
        }
        if device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) {
            device.focusMode = AVCaptureDevice.FocusMode.autoFocus
        }
        if device.isWhiteBalanceModeSupported(AVCaptureDevice.WhiteBalanceMode.autoWhiteBalance){
            device.whiteBalanceMode = AVCaptureDevice.WhiteBalanceMode.autoWhiteBalance
        }
        if device.isSmoothAutoFocusSupported {
            device.isSmoothAutoFocusEnabled = true
        }
        device.unlockForConfiguration()
    }
    
    func configureConnection()  {
        var videoConnection:AVCaptureConnection?
        for connection in self.videoDataOutput.connections {
            for port in connection.inputPorts{
                if port.mediaType == AVMediaType.video{
                    videoConnection = connection
                }
            }
        }
        if (videoConnection?.isVideoStabilizationSupported)!{
            let sysVer = Float(UIDevice.current.systemVersion)!
            if sysVer < 8.0 {
                videoConnection?.enablesVideoStabilizationWhenAvailable = true
            }else{
                videoConnection?.preferredVideoStabilizationMode = AVCap
            }
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
}

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
    
    lazy var  vedioCaptureDevice : AVCaptureDevice = {
        var device : AVCaptureDevice?
        var captureDevices : NSArray
        if #available(iOS 10, *){
            let devicesIOS10 = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.front)
            captureDevices = devicesIOS10.devices as NSArray
        }else{
            captureDevices = AVCaptureDevice.devices(for: AVMediaType.video) as NSArray
        }
        for  devices in captureDevices {
            if (devices as! AVCaptureDevice).position == .front{
                device = (devices as! AVCaptureDevice)
            }
        }
        return device!
    }()
    
    lazy var  audioCaptureDevice : AVCaptureDevice = {
        var device : AVCaptureDevice?
        var captureDevices : NSArray
        if #available(iOS 10, *){
            let devicesIOS10 = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInMicrophone], mediaType: AVMediaType.audio, position: AVCaptureDevice.Position.unspecified)
            captureDevices = devicesIOS10.devices as NSArray
        }else{
            captureDevices = AVCaptureDevice.devices(for: AVMediaType.audio) as NSArray
        }
        for  devices in captureDevices {
            device = (devices as! AVCaptureDevice)
        }
        return device!
    }()
    
    lazy var queue : DispatchQueue = {
       let queue = DispatchQueue.init(label: "www.captureQue.com")
        return queue
    }()
    
    lazy var moviesDataOutput : AVCaptureMovieFileOutput = {
        let  moviesDataOutput  = AVCaptureMovieFileOutput.init()
        return moviesDataOutput
    }()
    
    lazy var videoDataOutput : AVCaptureVideoDataOutput = {
       let videoDataOutput = AVCaptureVideoDataOutput.init()
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
       return videoDataOutput
    }()
    
    lazy var audioDataOutput:AVCaptureAudioDataOutput = {
       let audioDataOutput = AVCaptureAudioDataOutput.init()
        return audioDataOutput
    }()
    
    var activeVideoInput : AVCaptureDeviceInput?
    var videoConnection:AVCaptureConnection?

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
            captureSession.stopRunning()
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
        for connection in self.moviesDataOutput.connections {
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
                videoConnection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
        }
    }
    
    func configureOutPut() -> Bool {
        if self.captureSession.canAddOutput(self.moviesDataOutput) {
            self.captureSession.addOutput(self.moviesDataOutput)
        }else{
            return false
        }
        return true
    }
    
    func configureActiveInPut(vedioDevice : AVCaptureDevice,audioDevice : AVCaptureDevice) -> Bool {
        do {
            let videoInput  = try? AVCaptureDeviceInput.init(device: vedioDevice)
            let audioInput  = try? AVCaptureDeviceInput.init(device: audioDevice)
            if (videoInput != nil && audioInput != nil) {
                if  self.captureSession.canAddInput(videoInput!)  {
                    self.captureSession.addInput(videoInput!)                      }
                if  self.captureSession.canAddInput(audioInput!){
                    self.captureSession.addInput(audioInput!)
                }
                self.activeVideoInput = videoInput
            }else{
                return false
            }
        } catch let printerError as Error {
            print(printerError)
            return false
        }
        return true
    }
    
    func getUploadFileName(_ name:String,type:String) -> String {
        let now = NSDate.init().timeIntervalSince1970
        let formatter = DateFormatter.init()
        formatter.dateFormat = "HHmmss"
        let nowDate = NSDate.init(timeIntervalSince1970: now)
        let timeStr  = formatter.string(from: nowDate as Date)
        return name + timeStr + type
    }
    
    
    
    
    
    
    
    
    
}

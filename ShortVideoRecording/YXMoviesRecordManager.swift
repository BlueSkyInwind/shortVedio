//
//  YXRecordManager.swift
//  ShortVideoRecording
//
//  Created by admin on 2017/12/6.
//  Copyright © 2017年 WangYongxin. All rights reserved.
//

import UIKit
import AVFoundation

typealias StartRecordConnecions = (_ captureOutput:AVCaptureFileOutput) -> Void
typealias EndRecordConnecions = (_ captureOutput:AVCaptureFileOutput,_ outputFileURL:NSURL) -> Void

class YXMoviesRecordManager: YXBaseRecordManager,AVCaptureFileOutputRecordingDelegate {
    
    
    var recordTimer:Timer?
    var startRecordConnections:StartRecordConnecions?
    var endRecordConnecions:EndRecordConnecions?

    override init() {
        super.init()
        
    }
    
    func configureSession() -> Bool {
        self.captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
        if !self.configureOutPut() || !self.configureActiveInPut(vedioDevice: self.vedioCaptureDevice, audioDevice: self.audioCaptureDevice){
            return false
        }
        self.configureConnection()
        self.activeDeviceConfigure(device: self.vedioCaptureDevice)
        self.captureSession.commitConfiguration()
        self.captureSession.startRunning()
        return true
    }
    
    func startRecordingToOutputFileURL()  {
        
        // 2、直接开始写入文件
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + self.getUploadFileName("/abc", type: ".mp4")
        let fileUrl = URL(fileURLWithPath: filePath)
        self.moviesDataOutput.startRecording(to: fileUrl, recordingDelegate: self)
    }
    
    func stopRecordingToOutputFileURL()  {
        self.moviesDataOutput.stopRecording()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("开始录制")
        if (self.startRecordConnections != nil) {
            self.startRecordConnections!(output)
        }
     }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
          print("停止录制");
        if (self.endRecordConnecions != nil) {
            self.endRecordConnecions!(output,outputFileURL as NSURL)
        }
    }
    

    func convertVideoQuailtyWithInputURL(_ inputPath:String,outputPath:String) -> Void {
        let avAsset = AVURLAsset.init(url: URL.init(string: inputPath)!, options: [:])
        let exportSession = AVAssetExportSession.init(asset: avAsset, presetName: AVAssetExportPreset640x480)
        exportSession?.outputURL = URL.init(fileURLWithPath: outputPath)
        exportSession?.outputFileType = AVFileType.mp4
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.exportAsynchronously(completionHandler: {
            print("\(exportSession?.status)")
            if exportSession?.status == AVAssetExportSessionStatus.completed{
                print("压缩完成")
            }
            if exportSession?.status == AVAssetExportSessionStatus.failed {
                print("压缩失败")
            }
        })
        
        AVAssetExportSession.determineCompatibility(ofExportPreset: AVAssetExportPreset640x480, with: avAsset, outputFileType: AVFileType.mp4) { (isSuccess) in
            print("\(isSuccess)")
        }
    }
    
    
}

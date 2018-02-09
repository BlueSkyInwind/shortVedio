//
//  ViewController.swift
//  ShortVideoRecording
//
//  Created by admin on 2017/12/6.
//  Copyright © 2017年 WangYongxin. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    let RecordsTimeMax = 9  //录制最大时间
    let RecordsTimeMin = 0  //录制最小时间
    var keepTime:Int = 0
    var isVideoRecording:Bool = false
    
    var recordView:YXRecordView?
    var recordManager:YXMoviesRecordManager?
    var player:YXAVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        recordManager = YXMoviesRecordManager.init()
        
        //MARK:视图逻辑
        recordView = YXRecordView.init(frame: UIScreen.main.bounds)
        
        //点击录制
        recordView?.recordButtonClick = {[weak self] in
            self?.recordManager?.startRecordingToOutputFileURL()
        }
        //点击离开时 停止录制
        recordView?.stopRecordButtonClick = {[weak self] in
            self?.stopOutputRecording()
        }
        //重新录制
        recordView?.afreshButtonClick = {
            self.player?.isHidden = true
            self.player?.stopPlaye()
            self.recordView?.startRecordingAnimation()
        }
        //上传录制信息
        recordView?.ensureButtonClick = {
            print("开始上传")
            
        }
        self.view.insertSubview(recordView!, at: 0)
        
        //MARK:视频录制
        if (recordManager?.configureSession())!{
            let previewLayer = AVCaptureVideoPreviewLayer.init(session: (self.recordManager?.captureSession)!)
            previewLayer.frame = UIScreen.main.bounds
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.recordManager?.videoConnection?.videoOrientation = (previewLayer.connection?.videoOrientation)!
            recordView?.layer.insertSublayer(previewLayer, at: 0)
            self.recordManager?.startSession()
        }
        
        //MARK:开始写入录制
        recordManager?.startRecordConnections = {[weak self](captureOutput) in
            self?.keepTime = (self?.RecordsTimeMax)!;
            self?.perform(#selector(self?.onStartTranscribe(output:)), with: captureOutput, afterDelay: 0)
        }
        
        //MARK:拍摄完成是调用  结束写入录制
        recordManager?.endRecordConnecions = {[weak self](captureOutput,outputFileURL) in
            self?.endRecordChange()
            //增加录制播放预览层
            if self?.player == nil {
                self?.player = YXAVPlayer.init(frame: (UIScreen.main.bounds), bgview: (self?.recordView)!, url: outputFileURL as URL)
                self?.recordView?.bringSubview(toFront: (self?.recordView?.afreshBtn)!)
                self?.recordView?.bringSubview(toFront: (self?.recordView?.ensureBtn)!)
            }else{
                self?.player?.videoURL = outputFileURL as URL
                self?.player?.isHidden = false
            }
        }
    }
    
    //MARK:录制计时
    @objc func onStartTranscribe(output: AVCaptureFileOutput)  {
        if output.isKind(of:  AVCaptureMovieFileOutput.self) {
            keepTime -= 1
            if keepTime > 0 {
                if RecordsTimeMax - keepTime >= RecordsTimeMin && !isVideoRecording{
                    self.recordView?.isRecordingAnimation()
                    isVideoRecording = true
                    self.recordView?.bgView?.timeMax = Double(keepTime)
                }
                self.perform(#selector(onStartTranscribe(output:)), with: output, afterDelay: 1)
            }
            else{
                //计时结束时 停止录制
                if output.isRecording{
                    stopOutputRecording()
                }
            }
        }
    }
    
    //结束录制时状态改变
    func endRecordChange()  {
        self.recordView?.bgView?.clearProgress()
        self.recordView?.endRecordingAnimation()
    }
    
    //结束录制
    func stopOutputRecording()  {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        isVideoRecording = false
        recordManager?.stopRecordingToOutputFileURL()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


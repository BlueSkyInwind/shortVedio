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
        
        //视图逻辑
        recordView = YXRecordView.init(frame: UIScreen.main.bounds)
        //点击录制
        recordView?.recordButtonClick = {[weak self] in
            self?.recordManager?.startRecordingToOutputFileURL()
        }
        //停止录制
        recordView?.stopRecordButtonClick = {[weak self] in
            self?.recordManager?.stopRecordingToOutputFileURL()
        }
        
        recordView?.afreshButtonClick = {
            self.player?.isHidden = true
            self.player?.stopPlaye()
            self.recordView?.startRecordingAnimation()
        }
        
        recordView?.ensureButtonClick = {
            print("开始上传")
        }
        self.view.insertSubview(recordView!, at: 0)
        
        //视频录制
        if (recordManager?.configureSession())!{
            let previewLayer = AVCaptureVideoPreviewLayer.init(session: (self.recordManager?.captureSession)!)
            previewLayer.frame = UIScreen.main.bounds
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.recordManager?.videoConnection?.videoOrientation = (previewLayer.connection?.videoOrientation)!
            recordView?.layer.insertSublayer(previewLayer, at: 0)
            self.recordManager?.startSession()
        }
        
        recordManager?.startRecordConnections = {[weak self](captureOutput) in
            self?.keepTime = (self?.RecordsTimeMax)!;
            self?.perform(#selector(self?.onStartTranscribe(output:)), with: captureOutput, afterDelay: 0)
        }
        
        //拍摄完成是调用
        recordManager?.endRecordConnecions = {[weak self](captureOutput,outputFileURL) in
            self?.endRecordChange()
            if self?.player == nil {
                self?.player = YXAVPlayer.init(frame: (self?.view.bounds)!, bgview: (self?.recordView)!, url: outputFileURL as URL)
            }else{
                self?.player?.videoURL = outputFileURL as URL
                self?.player?.isHidden = false
            }
        }
    }
    
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
                if output.isRecording{
                    isVideoRecording = false
                    recordManager?.stopRecordingToOutputFileURL()
                }
            }
        }
    }
    
    func endRecordChange()  {
        self.recordView?.bgView?.clearProgress()
        self.recordView?.endRecordingAnimation()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


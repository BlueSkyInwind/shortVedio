//
//  YXAVPlayer.swift
//  ShortVideoRecording
//
//  Created by admin on 2017/12/19.
//  Copyright © 2017年 WangYongxin. All rights reserved.
//

import UIKit
import AVFoundation

class YXAVPlayer: UIView {

    var videoURL:URL?{
        didSet{
            self.removeAvPlayerNtf()
            nextPlayer()
        }
    }
        
    lazy var player:AVPlayer = {
        let player = AVPlayer.init(playerItem: AVPlayerItem.init(url: videoURL!))
        return player
    }()
    
    var playerLayer:AVPlayerLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame:CGRect,bgview:UIView,url:URL){
        self.init(frame: frame)
        self.videoURL = url
        playerLayer = AVPlayerLayer.init(player: self.player)
        playerLayer?.frame = frame
        self.layer.addSublayer(playerLayer!)
        bgview.insertSubview(self, at: 0)
    }

    func nextPlayer()  {
//        self.player.seek(to: CMTime.init(seconds: 0, preferredTimescale: (self.player.currentItem?.duration.timescale)!))
//        self.player.seek(to: <#T##CMTime#>, toleranceBefore: <#T##CMTime#>, toleranceAfter: <#T##CMTime#>, completionHandler: <#T##(Bool) -> Void#>)
        self.player.replaceCurrentItem(with: AVPlayerItem.init(url: videoURL!))
        self.addAVPlayerNtf(playerItem: self.player.currentItem!)
        if self.player.rate == 0 {
            self.player.play()
        }
    }
    
    func stopPlaye()  {
        if self.player.rate == 1{
            self.player.pause()
        }
    }
    
    func addAVPlayerNtf(playerItem:AVPlayerItem)  {
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
    }
    
    @objc func playbackFinished(ntf:Notification){
        self.player.seek(to: CMTime.init(value: 0, timescale: 1))
        self.player.play()
    }
    
    func removeAvPlayerNtf()  {
        NotificationCenter.default.removeObserver(self)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

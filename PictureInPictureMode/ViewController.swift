//
//  ViewController.swift
//  PictureInPictureMode
//
//  Created by Vineet Choudhary on 11/12/20.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var pictureInPictureManager: PictureInPictureManager?
    private var timeControlStatusObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let videoURL = URL(string: "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch  {
            debugPrint("Error in setting audio session category. Error -\(error.localizedDescription)")
        }
        
        //Create AVPlayer and AVPlayerLayer
        player = AVPlayer(url: videoURL!)
        playerLayer = AVPlayerLayer(player: player)
        checkPlayerTimeControlStatus()
        
        //Create PictureInPictureManager with playerLayer to enable PiP Mode
        pictureInPictureManager = PictureInPictureManager(playerLayer: playerLayer, isLive: false)
        
        //Added playerLayer to playerView
        playerView.layer.addSublayer(playerLayer)
        playerView.backgroundColor = .black
        
        //Start Video playback
        player.play()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Update playerLayer frame
        playerLayer.frame = playerView.bounds
    }
    
    private func checkPlayerTimeControlStatus() {
        timeControlStatusObservation = player.observe(\AVPlayer.timeControlStatus, options: [.new]) { [weak self] _, change in
            guard let self = self, let newValue = change.newValue else {
                return
            }
            
            if newValue == .playing {
                self.activityIndicator.stopAnimating()
            } else {
                self.activityIndicator.startAnimating()
            }
        }
    }
}


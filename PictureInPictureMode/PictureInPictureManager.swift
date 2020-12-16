//
//  PictureInPictureManager.swift
//  PictureInPictureMode
//
//  Created by Vineet Choudhary on 11/12/20.
//  Copyright © 2020 Developer Insider. All rights reserved.
//

import Foundation
import AVKit

class PictureInPictureManager: NSObject {
    private let pipController: AVPictureInPictureController!
    private var pipPossibleObservation: NSKeyValueObservation?
    private var notificationCenter: NotificationCenter {
        return .default
    }
    
    init?(playerLayer: AVPlayerLayer, isLive: Bool) {
        //Check if avPlayerLayer avaialble and Picture In Picture Mode Supported
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            return nil
        }
        
        //Creates a new Picture in Picture controller.
        pipController = AVPictureInPictureController(playerLayer: playerLayer)
        super.init()
        
        //For live content, disable seek forward/backward button
        if #available(iOS 14.0, *) {
            pipController.requiresLinearPlayback = isLive
        }
        
        if #available(iOS 14.2, *) {
            pipController.canStartPictureInPictureAutomaticallyFromInline = true
        }
        
        //Set Picture in Picture controller’s delegate object
        pipController.delegate = self
        
        //Observe willResignActiveNotification notification to start Picture In Picture Mode
        notificationCenter.addObserver(self, selector: #selector(appWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        
        pipPossibleObservation = pipController.observe(\AVPictureInPictureController.isPictureInPicturePossible, options: [.initial, .old, .new]) { _, change in
            debugPrint("[PiP] - \(change)")
        }
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    @objc private func appWillResignActive(_ notification: NSNotification) {
        pipController.startPictureInPicture()
    }
}

extension PictureInPictureManager: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        debugPrint("[PiP] - Stoped.")
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        debugPrint("[PiP] - Started.")
    }
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        debugPrint("[PiP] - Will Stop.")
    }
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        debugPrint("[PiP] - Will Start.")
        //force start playback again
        pictureInPictureController.playerLayer.player?.play()
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        debugPrint("[PiP] - Failed to Start. Error - \(error.localizedDescription)")
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        debugPrint("[PiP] - Restore User Interface.")
        completionHandler(true)
    }
}

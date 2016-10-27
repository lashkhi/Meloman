//
//  PlayerView.swift
//  Meloman
//
//  Created by David Lashkhi on 27/10/2016.
//  Copyright © 2016 David Lashkhi. All rights reserved.
//

import UIKit
import AVFoundation


class PlayerView: UIView {

    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

}

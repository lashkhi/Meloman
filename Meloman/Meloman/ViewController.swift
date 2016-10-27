//
//  ViewController.swift
//  Meloman
//
//  Created by David Lashkhi on 27/10/2016.
//  Copyright © 2016 David Lashkhi. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit


class ViewController: UIViewController {
    static let assetKeysRequiredToPlay = [
        "playable",
        "hasProtectedContent"
    ]
    var player : AVPlayer?
    @IBOutlet weak var playerView: PlayerView!
    
    private var playerLayer: AVPlayerLayer? {
        return playerView.playerLayer
    }
    
    var asset: AVURLAsset? {
        didSet {
            guard let newAsset = asset else { return }
            
            asynchronouslyLoadURLAsset(newAsset)
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startPlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        playerView.playerLayer.player = player

    }
    
    
    func startPlayer() {
        let videoURL = NSURL(string: "http://www.listenlive.eu/bbcradio1.m3u")
        player = AVPlayer(url: videoURL! as URL)
    }
    
    @IBAction func playPauseButtonWasPressed(_ sender: UIButton) {
        if player?.rate != 1.0 {
            // Not playing forward, so play.
            
            player?.play()
        }
        else {
            // Playing, so pause.
            player?.pause()
        }
    }

    func asynchronouslyLoadURLAsset(_ newAsset: AVURLAsset) {
        
        newAsset.loadValuesAsynchronously(forKeys: ViewController.assetKeysRequiredToPlay) {
            /*
             The asset invokes its completion handler on an arbitrary queue.
             To avoid multiple threads using our internal state at the same time
             we'll elect to use the main thread at all times, let's dispatch
             our handler to the main queue.
             */
            DispatchQueue.main.async {
                /*
                 `self.asset` has already changed! No point continuing because
                 another `newAsset` will come along in a moment.
                 */
                guard newAsset == self.asset else { return }
                
                /*
                 Test whether the values of each of the keys we need have been
                 successfully loaded.
                 */
                for key in PlayerViewController.assetKeysRequiredToPlay {
                    var error: NSError?
                    
                    if newAsset.statusOfValue(forKey: key, error: &error) == .failed {
                        let stringFormat = NSLocalizedString("error.asset_key_%@_failed.description", comment: "Can't use this AVAsset because one of it's keys failed to load")
                        
                        let message = String.localizedStringWithFormat(stringFormat, key)
                        
                        self.handleErrorWithMessage(message, error: error)
                        
                        return
                    }
                }
                
                // We can't play this asset.
                if !newAsset.isPlayable || newAsset.hasProtectedContent {
                    let message = NSLocalizedString("error.asset_not_playable.description", comment: "Can't use this AVAsset because it isn't playable or has protected content")
                    
                    self.handleErrorWithMessage(message)
                    
                    return
                }
                
                /*
                 We can play this asset. Create a new `AVPlayerItem` and make
                 it our player's current item.
                 */
                self.playerItem = AVPlayerItem(asset: newAsset)
            }
        }
    }
    


}


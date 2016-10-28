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


private var playerVCKVOContext = 0
let urlString = "http://www.listenlive.eu/bbcradio1.m3u"


class ViewController: UIViewController {
    
    static let assetKeysRequiredToPlay = [
        "playable",
        "hasProtectedContent"
    ]
    
    let player = AVPlayer()
    
    
    var rate: Float {
        get {
            return player.rate
        }
        
        set {
            player.rate = newValue
        }
    }
    
    var asset: AVURLAsset? {
        didSet {
            guard let newAsset = asset else { return }
            asynchronouslyLoadURLAsset(newAsset)
        }
    }
    
    
    private var playerItem: AVPlayerItem? = nil {
        didSet {

            player.replaceCurrentItem(with: self.playerItem)
        }
    }
    
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addObserver(self, forKeyPath: #keyPath(ViewController.player.rate), options: [.new, .initial], context: &playerVCKVOContext)
        
        let radioURL = URL(string: urlString)!
        asset = AVURLAsset(url: radioURL, options: nil)
        
        player.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        player.pause()
        
        removeObserver(self, forKeyPath: #keyPath(ViewController.player.rate), context: &playerVCKVOContext)
        
    }
    
    
    func asynchronouslyLoadURLAsset(_ newAsset: AVURLAsset) {
        
        newAsset.loadValuesAsynchronously(forKeys: ViewController.assetKeysRequiredToPlay) {
            DispatchQueue.main.async {
                guard newAsset == self.asset else { return }
                for key in ViewController.assetKeysRequiredToPlay {
                    var error: NSError?
                    
                    if newAsset.statusOfValue(forKey: key, error: &error) == .failed {
                        let stringFormat = "Can't use this AVAsset because one of it's keys failed to load"
                        
                        let message = String.localizedStringWithFormat(stringFormat, key)
                        
                        self.handleErrorWithMessage(message, error: error)
                        
                        return
                    }
                }
                
                if !newAsset.isPlayable || newAsset.hasProtectedContent {
                    let message = "Can't use this AVAsset because it isn't playable or has protected content"
                    
                    self.handleErrorWithMessage(message)
                    
                    return
                }
                
                self.playerItem = AVPlayerItem(asset: newAsset)
            }
        }
    }
    
    @IBAction func playPauseButtonWasPressed(_ sender: UIButton) {
        if player.rate != 1.0 {
            player.play()
        }
        else {
            player.pause()
        }
    }
    
    
    // MARK: - KVO Observation
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &playerVCKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(ViewController.player.rate) {
            
            let newRate = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).doubleValue
            let buttonImageName = newRate == 1.0 ? "Pause" : "Play"
            let buttonImage = UIImage(named: buttonImageName)
            playPauseButton.setImage(buttonImage, for: UIControlState())
        }
    }
    
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        let affectedKeyPathsMappingByKey: [String: Set<String>] = [
            "rate":         [#keyPath(ViewController.player.rate)]
        ]
        
        return affectedKeyPathsMappingByKey[key] ?? super.keyPathsForValuesAffectingValue(forKey: key)
    }
    
    // MARK: - Error Handling
    
    func handleErrorWithMessage(_ message: String?, error: Error? = nil) {
        NSLog("Error occured with message: \(message), error: \(error).")
        
        let alertTitle = "Error"
        let defaultAlertMessage = "Something went wrong"
        
        let alert = UIAlertController(title: alertTitle, message: message == nil ? defaultAlertMessage : message, preferredStyle: UIAlertControllerStyle.alert)
        
        let alertActionTitle = "OK"
        
        let alertAction = UIAlertAction(title: alertActionTitle, style: .default, handler: nil)
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }

}


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

    override func viewDidLoad() {
        super.viewDidLoad()
        startPlayer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startPlayer() {
        let videoURL = NSURL(string: "http://www.listenlive.eu/bbcradio1.m3u")
        let player = AVPlayer(url: videoURL! as URL)
        let playerViewController = AVPlayerViewController ()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }


}


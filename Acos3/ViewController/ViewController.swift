//
//  ViewController.swift
//  Acos3
//
//  Created by mac on 2021/05/10.
//

import UIKit
import AVKit


class ViewController: UIViewController {
    
    
    var videoPlayer : AVPlayer?
    
    var videoPlayerLayer : AVPlayerLayer?
    
    
    

    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setUpElements()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        setUpVideo()
    }
    


    
    
    func setUpElements(){
        Utilities.styleFilledButton(signUpButton)
        
        Utilities.styleHollowButton(loginButton)
    }
    
    
    
    func setUpVideo() {
        // get the path to te resource in the bundel
        let bundelPath =  Bundle.main.path(forResource: "moments", ofType: "mp4")
        
        guard bundelPath != nil else {
            return
        }
        
        // Create a URL from it
        let url = URL(fileURLWithPath: bundelPath!)
        
        
        // create the video player item
        let item = AVPlayerItem(url: url)
        
        // creat the player
        videoPlayer = AVPlayer(playerItem: item)
        
        // create the layer
        videoPlayerLayer = AVPlayerLayer(player: videoPlayer!)
        
        // Adjust the size and frame 프레임을 조정해서 영상크기를 맞춘다
        videoPlayerLayer?.frame = CGRect(x: -self.view.frame.size.width*1.5,
                                         y: -self.view.frame.size.width,
                                         width: self.view.frame.size.width*4,
                                         height: self.view.frame.size.height*2)
        
        
        
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)
        
        
        // Add it to the view and play it
        videoPlayer?.playImmediately(atRate: 1.5)
        
    }
    
    
    
}


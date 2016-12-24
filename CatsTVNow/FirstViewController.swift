//
//  FirstViewController.swift
//  CatsTVNow
//
//  Created by Johann Kerr on 12/23/16.
//  Copyright © 2016 Johann Kerr. All rights reserved.
//

import UIKit
import AVFoundation
import SVProgressHUD
class FirstViewController: UIViewController {

    let store = CatDataStore.sharedInstance
    var playCount = 0
    lazy var avPlayerLayer: AVPlayerLayer = AVPlayerLayer()
    lazy var backGroundPlayerLayer: AVPlayerLayer = AVPlayerLayer()
    
    lazy var titleView = TitleView()
    lazy var upNextImage = UIImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show(withStatus: "Loading all the Cats Right Meow!")
        store.getVideos {
            self.setupVideos(self.store.catVideos)
            
            
        }
        
    }
    
    func setupViews() {
        let frame = CGRect(x: 30, y: self.view.bounds.maxY - 150, width: 750, height: 100)
        
        
        let imageSize: CGFloat = 400
    
        
        let imageFrame = CGRect(x: self.view.bounds.maxX - imageSize, y: self.view.bounds.maxY - imageSize, width: imageSize, height: imageSize)
        
        self.upNextImage = UIImageView(frame: imageFrame)
        
        
        self.titleView = TitleView(frame: frame)
        titleView.setTitle("JOHANN WAS HERE")
        
        
        titleView.titleLabel.backgroundColor = UIColor.brown
        self.titleView.layer.cornerRadius = 25
        setupConstraints()
        
        store.getImageData(forCat: self.store.catVideos[playCount+1]) { (data) in
            OperationQueue.main.addOperation {
                let image = UIImage(data: data)
                self.upNextImage.image = image
            }
        }
        //self.view.insertSubview(self.titleView, at: 0)
        self.avPlayerLayer.addSublayer(self.titleView.layer)
        self.avPlayerLayer.addSublayer(self.upNextImage.layer)
        
    }
    
    func setupConstraints() {
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 50)
        titleView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100)
        titleView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.3)
        titleView.widthAnchor.constraint(equalToConstant: 400)
    }
    
    func setupVideos(_ videos:[CatVideo]) {
        var avPlayerItemArray = [AVPlayerItem]()
        for video in videos {
            if let url = URL(string: video.url) {
                print(url)
                let avplayerItem = AVPlayerItem(url: url)
                avPlayerItemArray.append(avplayerItem)
                let avplayerItemDos = AVPlayerItem(url: url)
                avPlayerItemArray.append(avplayerItemDos)
                NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avplayerItemDos)
            }
            
        }
        print("URL COUNT \(avPlayerItemArray.count)")
        
        OperationQueue.main.addOperation {
            let playerQueue = AVQueuePlayer(items: avPlayerItemArray)
            self.avPlayerLayer = AVPlayerLayer(player: playerQueue)
            self.avPlayerLayer.frame = self.view.bounds
            self.avPlayerLayer.videoGravity = Size.resize.description()
            
            self.view.layer.addSublayer(self.avPlayerLayer)
            self.avPlayerLayer.player?.play()
            SVProgressHUD.dismiss()
            
        

        }
        
        
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        print("did reach end")
   
        var playerItemArray = [AVPlayerItem]()

        self.playCount += 1
        self.titleView.setTitle(self.store.catVideos[playCount].title)
        store.getImageData(forCat: self.store.catVideos[playCount+1]) { (data) in
            OperationQueue.main.addOperation {
                let image = UIImage(data: data)
                self.upNextImage.image = image
            }
        }
        if self.playCount >= store.catVideos.count - 10 {
            print("getting more")
            self.store.getMoreVideos(completion: { (videos) in
                
                for video in videos {
                    if let url = URL(string: video.url) {
                        
                        let videoItem = AVPlayerItem(url: url)
                        playerItemArray.append(videoItem)
                        let videoItemDos = AVPlayerItem(url: url)
                        playerItemArray.append(videoItemDos)
                         NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoItemDos)
                        let queue = self.avPlayerLayer.player as! AVQueuePlayer
                        queue.insert(videoItem, after: queue.items().last!)
                    }
                    
                }
            })
        }
   
//        self.avPlayerLayer.player?.currentItem?.seek(to: kCMTimeZero)
//      
//        self.avPlayerLayer.player?.play()
    }
   
   

}

class TitleView: UIView {
    lazy var titleLabel = UILabel()
    
    init() {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        
        let frame = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.x, width: self.bounds.maxX, height: self.bounds.maxY)
        titleLabel = UILabel(frame: frame)
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: UIFontWeightThin)
        titleLabel.textAlignment = .center
        self.backgroundColor = UIColor.white
        self.addSubview(titleLabel)
        createConstraints()
    }
    
    func setTitle(_ value:String) {
        self.titleLabel.text = value
    }
    
    func createConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0).isActive = true
        self.titleLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0).isActive = true
        self.titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

enum Size {
    case aspect, fill, resize, resizeAspect
    func description() -> String {
        switch self {
        case .aspect:
            return AVLayerVideoGravityResizeAspectFill
        case .fill:
            return AVLayerVideoGravityResizeAspectFill
        case .resize:
            return AVLayerVideoGravityResize
        case .resizeAspect:
            return AVLayerVideoGravityResizeAspect
        }
    }
}


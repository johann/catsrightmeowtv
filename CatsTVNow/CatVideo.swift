//
//  CatVideo.swift
//  CatsTVNow
//
//  Created by Johann Kerr on 12/23/16.
//  Copyright © 2016 Johann Kerr. All rights reserved.
//

import Foundation


struct CatVideo {
    var url: String
    var thumbnail: String
    var title: String
    
    
    init(_ dict:[String:Any]) {
        let url = dict["url"] as? String ?? ""
        let thumbnail = dict["thumbnail"] as? String ?? ""
        let title = dict["title"] as? String ?? ""
        self.url = url
        self.thumbnail = thumbnail
        self.title = title
    }
    
    init(url:String, thumbnail:String, title:String) {
        self.title = title
        self.url = url
        self.thumbnail = thumbnail
    }
}


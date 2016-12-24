//
//  CatsApiClient.swift
//  CatsTVNow
//
//  Created by Johann Kerr on 12/23/16.
//  Copyright © 2016 Johann Kerr. All rights reserved.
//

import Foundation


enum Media {
    case video
    case gif
}

typealias JSONArray = [[String:Any]]

class CatsApiClient {
    class func getCats(type: Media,next:String, completion:@escaping (JSONArray,String)->()) {
        guard let url = URL(string:"https://catsrightmeow.herokuapp.com/\(type)s/\(next)") else { return }
        let session = URLSession.shared
        
     
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                let nextKey = responseJSON["next"] as? String ?? ""
                let responseArray = responseJSON["cats"] as! JSONArray
                
                completion(responseArray, nextKey)
            }catch {
                
            }
            
            
        }
        dataTask.resume()
    }
    
    class func getMoreCats(type: Media,next: String, completion:@escaping (JSONArray,String)->()) {
        guard let url = URL(string:"https://catsrightmeow.herokuapp.com/\(type)s/\(next)") else { return }
        let session = URLSession.shared
        
        
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                let nextKey = responseJSON["next"] as! String
                let responseArray = responseJSON["cats"] as! JSONArray
                
                completion(responseArray, nextKey)
            }catch {
                
            }
            
            
        }
        dataTask.resume()
    }
    
    
    class func getCatThumbail(cat: CatVideo, completion:@escaping (Data)->()) {
        guard let url = URL(string: cat.thumbnail) else { return }
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            completion(data)
            
        }
        dataTask.resume()
    }

}

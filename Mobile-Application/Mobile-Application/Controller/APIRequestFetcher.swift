//
//  APIRequestFetcher.swift
//  Mobile-Application
//
//  Created by Leonardo Febbo on 12/02/2020.
//  Copyright © 2020 Leonardo Febbo. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

enum NetworkError: Error {
    case failure
    case success
}


let APP_ID = "7f0eb8f2cdf6f33136bc854d89281085"
let HASH = "1bdc741bcbdaf3d87a0f0d6e6180f877"
let TS = "1"

class APIRequestFetcher {
    var searchResults = [JSON]()
    
    func search(searchText: String, completionHandler: @escaping ([JSON]?, NetworkError) -> ()) {
        
        
        let urlToSearch = "https://gateway.marvel.com/v1/public/series"
        let params : [String : String] = [ "apikey" : APP_ID, "ts": TS, "hash" : HASH, "contains": "comic", "orderBy" : "title", "limit" : "50", "titleStartsWith" : "\(searchText)"]
        
        Alamofire.request(urlToSearch, method: .get, parameters: params).responseJSON { response in
//            guard let data = response.data else {
//                completionHandler(nil, .failure)
//                return
//            }
            
            
            if response.result.isSuccess {
                            
                print("Success search")
                let json : JSON = JSON(response.result.value!)
                let results = json["data"]["results"].array
                
                completionHandler(results, .success)
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
                completionHandler(nil, .failure)
            }
            
            
            
        }
    }
    
    func fetchImage(url: String, completionHandler: @escaping (UIImage?, NetworkError) -> ()) {
        Alamofire.request(url).responseData { responseData in
            
            guard let imageData = responseData.data else {
                completionHandler(nil, .failure)
                return
            }
            
            guard let image = UIImage(data: imageData) else {
                completionHandler(nil, .failure)
                return
            }
            
            completionHandler(image, .success)
        }
    }
}

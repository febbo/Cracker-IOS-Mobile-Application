//
//  ImageDataModel.swift
//  Mobile-Application
//
//  Created by Leonardo Febbo on 26/09/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import Foundation

class ImageIssueDataModel {
    
    var imagePath : String = ""
    var imageExtension : String = ""
    
    
    init(path: String, ext: String){
        self.imagePath = path
        self.imageExtension = ext
        
    }
}

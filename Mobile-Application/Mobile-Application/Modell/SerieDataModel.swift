//
//  SerieDataModel.swift
//  Mobile-Application
//
//  Created by Leonardo Febbo on 12/08/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import Foundation

class SerieDataModel{
    
    var resourceURI : String = ""
    var title : String = ""
    
    init (URI: String, name: String){
        self.resourceURI = URI
        self.title = name
    }
    
}

//
//  CreatorDataModel.swift
//  Mobile-Application
//
//  Created by Leonardo Febbo on 12/08/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import Foundation

class CreatorDataModel {
    
    var resourceURI : String = ""
    var name : String = ""
    var role : String = ""
    
    init (URI: String, name: String, role: String){
        self.resourceURI = URI
        self.name = name
        self.role = role
    }
    
}

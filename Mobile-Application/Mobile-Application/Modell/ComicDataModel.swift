//
//  ComicDataModel.swift
//  Mobile-Application
//
//  Created by Leonardo Febbo on 12/08/2019.
//  Copyright © 2019 Leonardo Febbo. All rights reserved.
//

import Foundation


class ComicDataModel{
    //Declare your model variables here
    var title : String = ""
    var issueNumber : Int = 0
    var pageCount : Int = 0
    var resourceURI : String = ""
    var serie : SerieDataModel?
    var onsaleDate : Date?
    
    //per avere immagine path + https://developer.marvel.com/documentation/images + . + extension
    var imagePath : String = ""
    var imageExtension : String = ""
    
    var creators : [Creator] = []
    
    var charactersURI : String = ""
    var storiesURI : String = ""
    var eventsURI : String = ""
    
    
}

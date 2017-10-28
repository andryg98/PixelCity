//
//  Constants.swift
//  Pixel-City
//
//  Created by Andrea Garau on 21/10/2017.
//  Copyright © 2017 Andrea Garau. All rights reserved.
//

import UIKit
import MapKit


let apiKey = "e24914a3021eecb84f1038f63e30c074"

func flickrUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    let url =  "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(key)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=10&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    print(url)
    return url
}


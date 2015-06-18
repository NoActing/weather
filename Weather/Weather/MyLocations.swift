//
//  MyLocations.swift
//  Weather
//
//  Created by Simon Bozhilov on 31/05/15.
//  Copyright (c) 2015 Simon Bozhilov. All rights reserved.
//

import Foundation

class MyLocations {
    var myLoc = [LocationWeather]()
    //get all saved locations from Locations.plist
    func loadData(){
        myLoc.removeAll(keepCapacity: false)
        //plist
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent("Locations.plist")
        let fileManager = NSFileManager.defaultManager()
        // Check if file exists
        if(!fileManager.fileExistsAtPath(path)) {
            // If it doesn't, copy it from the default file in the Resources folder
            let bundle = NSBundle.mainBundle().pathForResource("Locations", ofType: "plist")
            fileManager.copyItemAtPath(bundle!, toPath: path, error:nil)
            println("Coppied from resources")
        }
        //read from Locations.plist and add to local array
        if var pListData = NSMutableDictionary(contentsOfFile: path) {
            if let locs = pListData.objectForKey("Locations") as? [[String: AnyObject]] {
                for l in locs {
                    let latP = l["Latitude"] as! String
                    let longP = l["Longitude"] as! String
                    let loc = LocationWeather(long: longP, lat: latP)
                    myLoc.append(loc)
                }
            }
        }
    }
    func saveToP(loc: LocationWeather) {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent("Locations.plist")
        let fileManager = NSFileManager.defaultManager()
        // Check if file exists
        if(!fileManager.fileExistsAtPath(path)) {
            
            // If it doesn't, copy it from the default file in the Resources folder
            let bundle = NSBundle.mainBundle().pathForResource("Locations", ofType: "plist")
            fileManager.copyItemAtPath(bundle!, toPath: path, error:nil)
            println("Coppied from resources")
        }
        
        //read
        if var pListData = NSMutableDictionary(contentsOfFile: path) {
            
            if let locs = pListData.objectForKey("Locations") as? [[String: AnyObject]] {
                println("Before save")
                for l in locs {
                    let latP = l["Latitude"] as! String
                    //println("LATITUDE: \(latP)")
                    let longP = l["Longitude"] as! String
                    //println("LONGITUDE: \(longP)")
                    let urlP = l["Url"] as! String
                    //println("URL: \(urlP)")
                }
                
                //write
                let location = ["Latitude": "\(loc.lat)", "Longitude": "\(loc.long)", "Url": "\(loc.url)" ] as NSDictionary
                var originalpListData = pListData.objectForKey("Locations") as! NSMutableArray
                originalpListData.addObject(location)
                pListData.setValue(originalpListData, forKey:"Locations")
                pListData.writeToFile(path, atomically: true)

            
            
            }
        }
    }
    
    func remove(){
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
            let documentsDirectory = paths.objectAtIndex(0) as! NSString
            let path = documentsDirectory.stringByAppendingPathComponent("Locations.plist")
            let fileManager = NSFileManager.defaultManager()
            if var pListData = NSMutableDictionary(contentsOfFile: path) {
                if let locs = pListData.objectForKey("Locations") as? [[String: AnyObject]] {
                    println("Before remove")
                    for l in locs {
                        let latP = l["Latitude"] as! String
                        println("LATITUDE: \(latP)")
                        let longP = l["Longitude"] as! String
                        println("LONGITUDE: \(longP)")
                        let urlP = l["Url"] as! String
                        println("URL: \(urlP)")
                        fileManager.removeItemAtPath(path, error: nil)
                    }
                    

                }
            }

    }
    func refreshData(){
        //clear local Array
        //myLoc.removeAll(keepCapacity: false)
        println("\(myLoc.count)")
        //load Data in local Array
        loadData()
        println("\(myLoc.count)")
        //remove()
        //Read local Array entries & update than add them to "Locations" Array in Locations.plist
        for loc in myLoc{
            let request = Request()
            request.send(loc.url, f: {(result: NSData) -> () in
                let json = JSON(data: result)
                for (index: String, subJson: JSON) in json["weather"] {
                    loc.weather = subJson["main"].stringValue
                    loc.weatherDescription = subJson["description"].stringValue
                }
                loc.temp = json["main"]["temp"].stringValue
                loc.windSpeed = json["wind"]["speed"].stringValue
                let area = json["name"].stringValue
                let country = json["sys"]["country"].stringValue
                loc.title = "\(area), \(country)"
                //self.saveToP(loc)
            })
            
        }
    }
}

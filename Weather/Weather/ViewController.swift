//
//  ViewController.swift
//  Weather
//
//  Created by Simon Bozhilov on 22/05/15.
//  Copyright (c) 2015 Simon Bozhilov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    var locationManager: CLLocationManager?
    var myLocationsUnsaved = [LocationWeather]()

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var gesture: UILongPressGestureRecognizer!
    
    
    @IBAction func mapTypeSelector(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            mapView.mapType = MKMapType.Standard
        case 1:
            mapView.mapType = MKMapType.Satellite
        case 2:
            mapView.mapType = MKMapType.Hybrid
        default:
            mapView.mapType = MKMapType.Standard
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
        self.mapView.delegate = self
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func pinMyLocation(sender: AnyObject) {
        myLocationsUnsaved.removeAll(keepCapacity: false)
        mapView.removeAnnotations(mapView.annotations)
        print("latitude: \(mapView.userLocation.coordinate.latitude)")
        //change the region same as current location
        let loc = CLLocationCoordinate2DMake(mapView.userLocation.coordinate.latitude, mapView.userLocation.coordinate.longitude)
        let regionCurent = MKCoordinateRegionMakeWithDistance(loc, 2000, 2000)
        mapView.setRegion(regionCurent , animated: true)
        //check weather        
        var data = LocationWeather(long: loc.longitude.description, lat: loc.latitude.description)
        let request = Request()
        request.send(data.url, f: {(result: NSData) -> () in
            let json = JSON(data: result)
            for (index: String, subJson: JSON) in json["weather"] {
                data.weather = subJson["main"].stringValue
                data.weatherDescription = subJson["description"].stringValue
            }
            data.temp = json["main"]["temp"].stringValue
            data.windSpeed = json["wind"]["speed"].stringValue
            let area = json["name"].stringValue
            data.title = "\(area)"
        })
        //add anotation
        var pin = MKPointAnnotation()
        pin.coordinate = loc
        pin.title = "Nearst weather station to you \(data.title)  "
        mapView.addAnnotation(pin)
        pin.subtitle = "\(data.weather), \(data.weatherDescription) / T:\(data.temp)C / Windspeed: \(data.windSpeed)"
        myLocationsUnsaved.append(data)
    }
    //tab 1 sec
    @IBAction func handleGesture(sender: UILongPressGestureRecognizer) {
        myLocationsUnsaved.removeAll(keepCapacity: false)
        mapView.removeAnnotations(mapView.annotations)
        var touchPoint = gesture.locationInView(self.mapView)
        var locationCordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        let regionCurent = MKCoordinateRegionMakeWithDistance(locationCordinates, 800, 800)
        mapView.setRegion(regionCurent , animated: true)

        //get weather
        var data = LocationWeather(long: locationCordinates.longitude.description, lat: locationCordinates.latitude.description)
        let request = Request()
        request.send(data.url, f: {(result: NSData) -> () in
            let json = JSON(data: result)
            for (index: String, subJson: JSON) in json["weather"] {
                data.weather = subJson["main"].stringValue
                data.weatherDescription = subJson["description"].stringValue
            }
            data.temp = json["main"]["temp"].stringValue
            data.windSpeed = json["wind"]["speed"].stringValue
            let area = json["name"].stringValue
            let country = json["sys"]["country"].stringValue
            data.title = "\(area), \(country)"
        })
        var newPin = MKPointAnnotation()
        newPin.coordinate = locationCordinates
        newPin.title = "Near weather station in \(data.title)"
        newPin.subtitle = "\(data.weather), \(data.weatherDescription) / T:\(data.temp)C / Wind speed: \(data.windSpeed)"
        myLocationsUnsaved.append(data)
        mapView.addAnnotation(newPin)
    }
    
    @IBAction func saveToP(sender: AnyObject) {
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
                for l in locs {
                    let latP = l["Latitude"] as! String
                    println("LATITUDE: \(latP)")
                    let longP = l["Longitude"] as! String
                    println("LONGITUDE: \(longP)")
                    let urlP = l["Url"] as! String
                    println("URL: \(urlP)")
                }
                
        //write
        let location = ["Latitude": "\(myLocationsUnsaved[0].lat)", "Longitude": "\(myLocationsUnsaved[0].long)", "Url": "\(myLocationsUnsaved[0].url)" ] as NSDictionary
        var originalpListData = pListData.objectForKey("Locations") as! NSMutableArray
        originalpListData.addObject(location)
        pListData.setValue(originalpListData, forKey:"Locations")
        pListData.writeToFile(path, atomically: true)

        }
     
        }
    }
    
    
    private func geoLocatorCallback(placemarks: [AnyObject]!, error: NSError!){
        if (error != nil){
            println("Error: \(error.localizedDescription)")
        }
        if placemarks.count > 0{
            let pm = placemarks.first as! CLPlacemark
            println(pm.locality)
            println(pm.country)
        }
    }
    
}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations[0] as! CLLocation
        pinIt(location)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {self.geoLocatorCallback($0, error: $1)})
        
        println("\(location.coordinate.latitude)" + " \(location.coordinate.longitude)" + " \(location.altitude)")
        locationManager?.stopUpdatingLocation()
        
    }
}

extension ViewController: MKMapViewDelegate{
    
    
    
    func pinIt(location: CLLocation){
        let mapPoint = MKMapPointForCoordinate(location.coordinate)
        let mapRect = MKMapRect(origin: mapPoint, size: MKMapSize(width: 0, height: 0))
        mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsetsMake(2000, 2000, 2000, 2000), animated: false)
        mapView.showsUserLocation = true
    }

}


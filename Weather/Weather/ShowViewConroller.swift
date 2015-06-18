//
//  ShowViewConroller.swift
//  Weather
//
//  Created by Simon Bozhilov on 01/06/15.
//  Copyright (c) 2015 Simon Bozhilov. All rights reserved.
//

import UIKit
import MapKit

class ShowViewController: UIViewController {
    
    var long: String = ""
    var lat: String = ""

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var weatheLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.mapType = MKMapType.Hybrid
        var loc = LocationWeather(long: long, lat: lat)
        loadData(loc)
    }
    
    func loadData(loc: LocationWeather){
        mapView.removeAnnotations(mapView.annotations)
        let clLoc = CLLocationCoordinate2DMake((Double((lat as NSString).doubleValue), Double((long as NSString).doubleValue)))
        let regionCurent = MKCoordinateRegionMakeWithDistance(clLoc, 8000, 8000)
        mapView.setRegion(regionCurent , animated: true)
        
        //get weather from jason
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
        })
        weatheLabel.text = "\(loc.weather) with \(loc.weatherDescription) \n T: \(loc.temp) ℃ apx."
        windLabel.text = "\(loc.windSpeed) m/s apx."
        
        //make annotation
        var newPin = MKPointAnnotation()
        newPin.coordinate = clLoc
        newPin.title = "Near weather station in \(loc.title)"
        newPin.subtitle = "\(loc.weather), \(loc.weatherDescription) / T:\(loc.temp)C / Wind speed: \(loc.windSpeed)"
        mapView.addAnnotation(newPin)

    }
}




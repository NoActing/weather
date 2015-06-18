//
//  LocationWeather.swift
//  Weather
//
//  Created by Simon Bozhilov on 25/05/15.
//  Copyright (c) 2015 Simon Bozhilov. All rights reserved.
//

import Foundation

class LocationWeather{
    let long: String
    let lat: String
    var title: String = ""
    var temp: String = ""
    var weather: String = ""
    var weatherDescription: String = ""
    var windSpeed: String = ""
    let url: String
    
    init(long: String, lat: String){
        self.long = long
        self.lat = lat
        self.url = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&units=metric"
        //ex url: http://api.openweathermap.org/data/2.5/weather?lat=56.1572&lon=10.2107&units=metric
        
    }
    
}

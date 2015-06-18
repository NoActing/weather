//
//  TableViewController.swift
//  Weather
//
//  Created by Simon Bozhilov on 28/05/15.
//  Copyright (c) 2015 Simon Bozhilov. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var table: UITableView!
   
    
    var list = MyLocations()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        list.refreshData()
        println("\(list.myLoc.count)")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var showView: ShowViewController = segue.destinationViewController as! ShowViewController
        var data = list.myLoc[table.indexPathForSelectedRow()!.row]
        var loc = LocationWeather(long: data.long, lat: data.lat)
        showView.long = data.long
        showView.lat = data.lat
    }
    @IBAction func refresh(sender: AnyObject) {
        list.refreshData()
        table.reloadData()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellWeather", forIndexPath: indexPath) as! CellViewController
        let data = list.myLoc[indexPath.row]
        cell.accessoryView?.setValue(data, forKey: "data")
        cell.weather.text = String("Weather is \(data.weather) with \(data.weatherDescription)")
        cell.temperature.text = String("Temperature at the moment is \(data.temp) ℃ apx.")
        cell.windSpeed.text = String("Wind speed is \(data.windSpeed) m/s apx.")
        cell.location.text = String("\(data.title)")
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.myLoc.count
    }

}

//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e543f9df9e2e3bec1f75595b4cc4f9c3"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
    //set the WeatherViewController i.e "self" as the delegate for the data that the locationManager fetches.
        locationManager.delegate = self
    //set the desired accuracy.
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    // Ask user for permission for location data. You must add two feilds to the info.plist file for this to work. Privacy Location Usage description && when in usage description.
        locationManager.requestWhenInUseAuthorization()
        
        // This is asynchronously searching for the gps location of the user. For this to work we need to write two other functions. See the "Location Manager Delegate Methods section below"
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    //We must now send http requests to get the data from openweathermaps api. the Alamofire pod will help us do this
    
    func getWeatherData(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                // response.result.value is returned to us in the form of an OPTIONAL so in order to use it, we have to force unwrap it with the exclamation mark. This is safe to do here because we already checked that we infact have a respnse on line 64.
                
                //Also "value" is of datatype any, thus we have to convert it to json. line 67
                
                
                self.updateWeatherData(json: weatherJSON)
                // we use the self keyword because, whenever you see the keyword "in" like on line 64, it means you're in a closure. i.e like a function in another function. self keyword should be used it cases like this.
                //updateWeatherData() function is called from the JSON Parsing section.
                
                
            } else {
                print("Error \(response.result.error)")
                self.cityLabel.text = "Conection Issues"
            }
        }
    }
    
    
    

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateWeatherData(json: JSON) {
        
        if let tempResult = json["main"]["temp"].double {
        
            weatherDataModel.temperature = Int(tempResult - 273.15)
        
            weatherDataModel.city = json["name"].stringValue
        
            weatherDataModel.condition = json["weather"][0]["id"].intValue
        
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
        } else {
            
            cityLabel.text = "Weather Unavailable"
            
        }
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    //if the locationManager finds the data, it stores it in the array [CLLocation] below. Assume the last index of the array is the most accurate location data.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count-1]
        //check if location value is valid
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            
            //print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)").
            // make these long/lat data into parameters that will be sent to the openweathermap api
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            
            //latitude and longitude are both of datatype "double" thus the reason we had to stringify them. params is a dictionary. NEXT step is to do some networking and send the request to open weather map.
            
            // Next we call the "getWeatherData()" function from the Networking Section and pass it the url of the api, and the parameters that the api specifies.
            getWeatherData(url: WEATHER_URL, parameters: params)
            
            
        }
    }
    
    
    
    //Write the didFailWithError method here:
    // If the locationManager can't find the location data, this function is triggered.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredANewCityName(city: String) {
        
        let params : [String: String] = ["q": city, "appid": APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
    }
    
    
}



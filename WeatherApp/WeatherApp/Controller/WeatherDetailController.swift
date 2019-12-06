//
//  WeatherDetailController.swift
//  WeatherApp
//
//  Created by Joshua Geronimo on 12/6/19.
//  Copyright © 2019 Joshua Geronimo. All rights reserved.
//

import UIKit
import Log

class WeatherDetailController: UIViewController {
    
    // MARK: UI ELEMENTS
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var weatherSummaryLabel: UILabel!
    
    @IBOutlet weak var sunriseTimeLabel: UILabel!
    @IBOutlet weak var sunsetTimeLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windspeedLabel: UILabel!
    
    fileprivate let log = Logger()
    var weatherInfo: WeatherData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = weatherInfo!.getFormattedDate()
        log.trace("viewDidLoad called")
        log.info(weatherInfo)
        setInitialInfo()
    }
    
    fileprivate func setInitialInfo() {
        weatherIcon.image = UIImage(named: weatherInfo!.icon)
        highTempLabel.text = "High: \(weatherInfo!.temperatureMax)°"
        lowTempLabel.text = "Low: \(weatherInfo!.temperatureMax)°"
        weatherSummaryLabel.text = weatherInfo!.summary
        sunriseTimeLabel.text = "Sunrise: \( weatherInfo!.getFormattedSunriseTime())"
        sunsetTimeLabel.text = "Sunset: \(weatherInfo!.getFormattedSunsetTime())"
        
        humidityLabel.text = "Humidity: \(weatherInfo!.humidity)"
        windspeedLabel.text = "Wind speed: \(weatherInfo!.windSpeed) mph"
        
    }
}

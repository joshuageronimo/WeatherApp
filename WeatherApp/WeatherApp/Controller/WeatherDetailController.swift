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
    @IBOutlet weak var hourlyTableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    fileprivate let log = Logger()
    fileprivate var hourlyWeatherData: [WeatherData] = []
    var weatherInfo: WeatherData?
    var urlString: String?
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = weatherInfo!.getFormattedDate()
        log.trace("viewDidLoad called")
        fetchWeatherData()
        setInitialInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        log.trace("viewWillDisappear called")
    }
    
    
    fileprivate func fetchWeatherData() {
        log.trace("Attempting to fetch hourly weather data")
        let url = "\(urlString!),\(Int(weatherInfo!.time))"
        DataService.shared.fetchData(urlString: url) { [unowned self] (data: Weather?, error: Error?) in
            if let error = error {
                self.failedToFetchData(error: error)
            }
            self.finishedFetching(data: data)
        }
    }
    
    func finishedFetching(data weather: Weather?) {
        log.trace("Data Fetched")
        if let weather = weather {
            hourlyWeatherData = weather.hourly.data
            DispatchQueue.main.async {
                self.hourlyTableView.reloadData()
            }
        }
        loadingIndicator.stopAnimating()
    }
    
    func failedToFetchData(error: Error) {
        log.error("Data Fetching Failed", error)
        loadingIndicator.stopAnimating()
    }
    
    // MARK: UI
    
    fileprivate func setInitialInfo() {
        weatherIcon.image = UIImage(named: weatherInfo!.icon)
        highTempLabel.text = "High: \(weatherInfo!.getFormattedHighTemperature())"
        lowTempLabel.text = "Low: \(weatherInfo!.getFormattedLowTemperature())"
        weatherSummaryLabel.text = weatherInfo!.summary
        sunriseTimeLabel.text = "Sunrise: \(weatherInfo!.getFormattedSunriseTime())"
        sunsetTimeLabel.text = "Sunset: \(weatherInfo!.getFormattedSunsetTime())"
        humidityLabel.text = "Humidity: \(weatherInfo!.humidity)"
        windspeedLabel.text = "Wind speed: \(weatherInfo!.windSpeed) mph"
    }
}

// TABLEVIEW

extension WeatherDetailController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

extension WeatherDetailController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = hourlyWeatherData.count
        log.info("Number of rows \(numberOfRows)")
        return numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherHourlyCell", for: indexPath) as? WeatherHourlyCell {
            cell.weatherData = hourlyWeatherData[indexPath.row]
            return cell
        }
        return WeatherHourlyCell()
    }
}

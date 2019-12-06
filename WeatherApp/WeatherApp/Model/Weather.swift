//
//  Weather.swift
//  WeatherApp
//
//  Created by Joshua Geronimo on 12/5/19.
//  Copyright © 2019 Joshua Geronimo. All rights reserved.
//

import Foundation

struct Weather: Decodable {
    let latitude: Double
    let longitude: Double
    let currently: CurrentWeather
    let daily: DailyWeather
}

// contains data for current date's weather
struct CurrentWeather: Decodable {
    let time: Double
    let summary: String
}

// contains this week and next week's weather data
struct DailyWeather: Decodable {
    let data: [WeatherData]
}

// contains weather data
struct WeatherData: Decodable {
    fileprivate let time: Double
    let icon: String
    let summary: String
    let temperatureMax: Double
    let temperatureMin: Double
    
    func getFormattedDate() -> String {
        let date = Date(timeIntervalSince1970: time)
        if date.distance(to: Date()) >= 0 {
            // if the current date is today's date return 'Today'
            return "Today"
        }
        
        let dateFormatter = DateFormatter()
        // EEE MM d == Mon, Dec 6
        dateFormatter.setLocalizedDateFormatFromTemplate("EEE MMM d")
        dateFormatter.timeZone = .current
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
}



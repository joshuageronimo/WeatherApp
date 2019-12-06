//
//  WeatherDayCell.swift
//  WeatherApp
//
//  Created by Joshua Geronimo on 12/5/19.
//  Copyright © 2019 Joshua Geronimo. All rights reserved.
//

import UIKit

class WeatherDayCell: UICollectionViewCell {
    // MARK: UI ELEMENTS
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var daySummaryLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    
    var weatherData: WeatherData? {
        didSet {
            if let weatherData = weatherData {
                dayLabel.text = weatherData.getFormattedDate()
                daySummaryLabel.text = weatherData.summary
                highTempLabel.text = "High: \(weatherData.temperatureMax)°"
                lowTempLabel.text = "Low: \(weatherData.temperatureMin)°"
                weatherIcon.image = UIImage(named: weatherData.icon)
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
}

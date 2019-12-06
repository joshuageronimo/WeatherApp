//
//  WeatherHourlyCell.swift
//  WeatherApp
//
//  Created by Joshua Geronimo on 12/6/19.
//  Copyright © 2019 Joshua Geronimo. All rights reserved.
//

import UIKit

class WeatherHourlyCell: UITableViewCell {
    // MARK: UI ELEMENTS
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    
    var weatherData: WeatherData? {
        didSet {
            if let weatherData = weatherData {
                timeLabel.text = weatherData.getFormattedHourlyTime()
                tempLabel.text = "\(weatherData.temperature!)°"
                weatherIcon.image = UIImage(named: weatherData.icon)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
}

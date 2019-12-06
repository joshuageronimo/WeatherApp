//
//  MainWeatherController.swift
//  WeatherApp
//
//  Created by Joshua Geronimo on 12/5/19.
//  Copyright © 2019 Joshua Geronimo. All rights reserved.
//

import UIKit

class MainWeatherController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        DataService.shared.fetchData(urlString: "42.3601,-71.0589") { (weather: Weather?, error: Error?) in
            
        }
    
    }

}


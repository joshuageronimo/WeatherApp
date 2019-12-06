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
    
    
    fileprivate let log = Logger()
    var weatherInfo: WeatherData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.trace("viewDidLoad called")
        log.info(weatherInfo)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

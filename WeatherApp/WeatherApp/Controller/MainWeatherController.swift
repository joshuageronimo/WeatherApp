//
//  MainWeatherController.swift
//  WeatherApp
//
//  Created by Joshua Geronimo on 12/5/19.
//  Copyright © 2019 Joshua Geronimo. All rights reserved.
//

import UIKit
import CoreLocation
import Log

class MainWeatherController: UIViewController {
    
    fileprivate var locationManager = CLLocationManager()
    fileprivate let log = Logger()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        log.trace("ViewDidLoad called")
        checkLocationServices()
    }
    
    fileprivate func fetchWeatherData() {
        log.trace("Attempting to fetch weather data")
        // get the devices current location coordinates
        guard let latitude = locationManager.location?.coordinate.latitude else { return }
        guard let longitude = locationManager.location?.coordinate.longitude else { return }
        // create url string - for this case just string of latitude & longitude
        let url = "\(latitude),\(longitude)"
        DataService.shared.fetchData(urlString: url) { (weather: Weather?, error: Error?) in
            
        }
    }
    
    // MARK: Location Service
    
    fileprivate func checkLocationServices() {
        log.trace("Checking Location Service")
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
    }
    
    fileprivate func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    fileprivate func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            log.trace("Location is enable!")
            fetchWeatherData()
        case .denied:
            // Show alert instructing them how to turn on permissions
            log.warning("Location Authorization Denied")
        case .notDetermined:
            log.trace("Location Authorization not determined")
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            log.warning("Location Authorization is restricted")
        @unknown default:
            log.warning("Location Authorization status is unknown")
        }
    }
}

// MARK: EXTENSION: CLLocationManagerDelegate

extension MainWeatherController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        log.trace("Location Authorization changed")
        checkLocationAuthorization()
    }
}


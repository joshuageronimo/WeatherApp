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
    
    
    // MARK: UI ELEMENTS
    @IBOutlet weak var weatherCollectionView: UICollectionView!
   
    
    
    // MARK: CONSTANT & VARIABLE
   
    fileprivate var locationManager = CLLocationManager()
    fileprivate let log = Logger()
    fileprivate var weatherData: [WeatherData] = []
    fileprivate let segueIdentifierToWeatherDetailController = "toWeatherDetailController"
    fileprivate var urlString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Weather"
        log.trace("ViewDidLoad called")
        checkLocationServices()
        
        
    }
    
    // Fetch weather data from DarkSky API
    fileprivate func fetchWeatherData() {
        log.trace("Attempting to fetch weather data")
        // get the devices current location coordinates
        guard let latitude = locationManager.location?.coordinate.latitude, let longitude = locationManager.location?.coordinate.longitude else {
            log.warning("Latitude or Longitude is nil")
            return
        }
        // set url string - for this case just string of latitude & longitude
        urlString = "\(latitude),\(longitude)"
        DataService.shared.fetchData(urlString: urlString, delegate: self)
    }
    
    // Set the navigation title to the user's current city
    fileprivate func setNavigationtitle() {
        if let lastLocation = locationManager.location {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(lastLocation) { [weak self] (placemarks, error) in
                if error == nil {
                    if let firstLocation = placemarks?[0], let cityName = firstLocation.locality {
                        self?.title = cityName.capitalized
                    }
                }
            }
        }
    }
    
    // MARK: NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifierToWeatherDetailController {
            
            if let destinationController = segue.destination as? WeatherDetailController {
                guard let weatherInfo = sender as? WeatherData else { return }
                destinationController.weatherInfo = weatherInfo
                destinationController.urlString = urlString
            }
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
            setNavigationtitle()
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

// MARK: CLLocationManager Delegate Functions

extension MainWeatherController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        log.trace("Location Authorization changed")
        checkLocationAuthorization()
    }
}

// MARK: CollectionView Delegates & DataSource functions

extension MainWeatherController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        log.trace("cell is tapped")
        let weatherInfo = weatherData[indexPath.item]
        performSegue(withIdentifier: segueIdentifierToWeatherDetailController, sender: weatherInfo)
        
    }
}

extension MainWeatherController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherDayCell", for: indexPath) as? WeatherDayCell {
            cell.weatherData = weatherData[indexPath.item]
            return cell
        }
        return WeatherDayCell()
    }
}

extension MainWeatherController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 115)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
        
        
    }
}

// MARK: NETWORK

extension MainWeatherController: DataFetcherDelegate {
    func finishedFetching(data weather: Weather?) {
        log.trace("Data Fetched")
        if let weatherData = weather?.daily.data {
            self.weatherData = weatherData
            DispatchQueue.main.async {
                self.weatherCollectionView.reloadData()
            }
        }
    }
    
    func failedToFetchData(error: Error) {
        log.error("Data Fetching Failed", error)
    }
}


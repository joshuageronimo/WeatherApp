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
    fileprivate let refreshControl = UIRefreshControl()

    // MARK: CONSTANT & VARIABLE
    
    fileprivate var locationManager = CLLocationManager()
    fileprivate let log = Logger()
    fileprivate var weatherData: [WeatherData] = []
    fileprivate let segueIdentifierToWeatherDetailController = "toWeatherDetailController"
    fileprivate var urlString = ""
    fileprivate let notificationCenter = UNUserNotificationCenter.current()
    fileprivate var hasShownAlert = false
    
    // Notification center property
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Weather"
        log.trace("ViewDidLoad called")
        self.userNotificationCenter.delegate = self
        requestNotificationAuthorization()
        checkLocationServices()
        setupRefreshControl()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        log.trace("viewWillDisappear called")
    }
    
    // MARK: UI
    
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
    
    // MARK: NETWORK
    
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
        DataService.shared.fetchData(urlString: urlString) { [unowned self] (data: Weather?, error: Error?) in
            if let error = error {
                self.failedToFetchData(error: error)
                return
            }
            self.finishedFetching(data: data)
        }
    }
    
    func finishedFetching(data weather: Weather?) {
        log.trace("Data Fetched")
        if let weatherData = weather?.daily.data {
            reloadCollectionViewWith(weatherData)
            checkIfNeedToSendLocalNotification(weatherData)
        }
    }
    
    func failedToFetchData(error: Error) {
        log.error("Data Fetching Failed", error)
        DispatchQueue.main.async {
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
        }
        // handle error code here
    }
    
    // MARK: Refresh Control
    
    fileprivate func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        weatherCollectionView.refreshControl = refreshControl
    }
    
    @objc func handleRefresh() {
        log.trace("Refreshing Data")
        fetchWeatherData()
    }
    fileprivate func reloadCollectionViewWith(_ weatherData: [WeatherData]) {
        // Reload Tableview with new data
        self.weatherData = weatherData
        DispatchQueue.main.async {
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.weatherCollectionView.reloadData()
        }
    }
    
    // MARK: NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifierToWeatherDetailController {
            if let destinationController = segue.destination as? WeatherDetailController {
                log.trace("going to WeatherDetailController")
                guard let weatherInfo = sender as? WeatherData else { return }
                destinationController.weatherInfo = weatherInfo
                destinationController.urlString = urlString
            }
        }
    }
    
    // MARK: LOCATION SERVICE
    
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
            // Show alert instructing them how to turn on permissions
            log.trace("Location Authorization not determined")
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show alert instructing them how to turn on permissions
            log.warning("Location Authorization is restricted")
        @unknown default:
            // Show alert instructing them how to turn on permissions
            log.warning("Location Authorization status is unknown")
        }
    }
    
    // MARK: NOTIFICATION
    
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        self.userNotificationCenter.requestAuthorization(options: authOptions) { [weak self] (success, error) in
            if let error = error {
                self?.log.error("Notification Auth Error: \(error)")
                // handle error code here...
            }
        }
    }

    // shows a local notification to the user
    func sendNotification() {
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Forecast"
        notificationContent.body = "It's going to snow in the next few days"
        notificationContent.badge = NSNumber(value: 1)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                        repeats: false)
        let request = UNNotificationRequest(identifier: "testNotification",
                                            content: notificationContent,
                                            trigger: trigger)
        
        userNotificationCenter.add(request) { [weak self] (error) in
            if let error = error {
                self?.log.error("Notification Error: \(error)")
                // handle error code here...
            }
        }
    }
    
    fileprivate func checkIfNeedToSendLocalNotification(_ weatherData: [WeatherData]) {
        // Trigger Local Notification if one or more days of the days of the week is going to snow
        if !hasShownAlert {
            log.trace("checking if need to send local notification")
            let weatherWithSnow = weatherData.filter { $0.icon == "snow" }
            if weatherWithSnow.count > 0 {
                log.trace("sending notification")
                hasShownAlert = true // should only show alert once in the apps lifetime
                self.sendNotification()
            } else {
                log.trace("no need to send notification")
            }
        } else {
            log.trace("notification was already shown")
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
        let numberOfItems = weatherData.count
        log.info("Number of items in collectionview: \(numberOfItems)")
        return numberOfItems
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

// MARK: NOTIFICATION DELEGATES

extension MainWeatherController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}


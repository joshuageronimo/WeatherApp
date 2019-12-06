//
//  DataService.swift
//  WeatherApp
//
//  Created by Joshua Geronimo on 12/5/19.
//  Copyright © 2019 Joshua Geronimo. All rights reserved.
//

import Foundation
import Alamofire
import Log

protocol DataFetcher {
    func finishedFetching(data weather: Weather?)
    
    func failedToFetchData(error: Error)
}

class DataService {
    
    static let shared = DataService()
    var delegate: DataFetcher?
    fileprivate let log = Logger()
    fileprivate let baseApiUrl = "https://api.darksky.net/forecast/"
    fileprivate let apiKey = "8428a15e4d22090c9b754dfdf9f97fb6"
    
    func fetchData(urlString: String, parameters: [String: String]? = nil, delegate: DataFetcher) {
        // set delegate
        self.delegate = delegate
        // create the apiURL
        let url = "\(baseApiUrl)\(apiKey)/\(urlString)"
        log.trace("GET REQUEST: \(url)")
        AF.request(url, method: .get, parameters: parameters)
            .responseDecodable(of: Weather.self) { [weak self] response in
                switch response.result {
                case .success:
                    self?.log.trace("Fetched Data Success")
                    self?.log.info(response.value as Any)
                    self?.delegate?.finishedFetching(data: response.value)
                case let .failure(error):
                    self?.log.error(error)
                    self?.delegate?.failedToFetchData(error: error)
                }
        }
    }
}

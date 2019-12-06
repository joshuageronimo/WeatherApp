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

class DataService {
    
    static let shared = DataService()
    fileprivate let log = Logger()
    
    fileprivate let baseApiUrl = "https://api.darksky.net/forecast/"
    fileprivate let apiKey = "8428a15e4d22090c9b754dfdf9f97fb6"
    
    func fetchData<T: Decodable>(urlString: String, parameters: [String: String]? = nil, completion: @escaping (T?, Error?) -> ()) {
        // create the apiURL
        let url = "\(baseApiUrl)\(apiKey)/\(urlString)"
        log.trace("GET REQUEST: \(url)")
        AF.request(url, method: .get, parameters: parameters)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success:
                    self.log.trace("Fetched Data Success")
                    self.log.info(response.value as Any)
                    completion(response.value, nil)
                case let .failure(error):
                    self.log.error(error)
                    completion(nil, error)
                }
        }
    }
}

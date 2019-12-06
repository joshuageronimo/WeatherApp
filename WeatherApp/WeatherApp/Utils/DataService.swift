//
//  DataService.swift
//  WeatherApp
//
//  Created by Joshua Geronimo on 12/5/19.
//  Copyright © 2019 Joshua Geronimo. All rights reserved.
//

import Foundation
import Alamofire

class DataService {
    
    static let shared = DataService()
    
    fileprivate let baseApiUrl = "https://api.darksky.net/forecast/"
    fileprivate let apiKey = "8428a15e4d22090c9b754dfdf9f97fb6"
    
    func fetchData<T: Decodable>(urlString: String, parameters: [String: String]? = nil, completion: @escaping (T?, Error?) -> ()) {
    
        // create the apiURL
        let url = "\(baseApiUrl)\(apiKey)/\(urlString)"
        
        AF.request(url, method: .get, parameters: parameters)
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success:
                    // TODO: LOG SUCCESS
                    print("Validation Successful")
                    completion(response.value, nil)
                case let .failure(error):
                    completion(nil, error)
                    // TODO: LOG ERROR
                    print(error)
                }
        }
    }
}

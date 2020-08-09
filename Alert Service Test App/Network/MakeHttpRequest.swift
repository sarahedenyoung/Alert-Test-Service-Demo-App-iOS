//
//  RegisterDevice.swift
//  Alert Service Test App
//
//  Created by Sarah Young on 8/4/20.
//  Copyright © 2020 Sarah Young. All rights reserved.
//

import Foundation

final class MakeHttpRequest {
    
    static let sharedInstance = MakeHttpRequest()
    var url_base = "https://sfdc-scrt-sarah-young.herokuapp.com/"
    
    func postRequest (api: String, parameters: [String: Any]? = nil) {
        guard let destination = URL(string: url_base + api) else { return }
        var request = URLRequest(url: destination)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let parameters = parameters {
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return
            }
            request.httpBody = httpBody
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: (\(httpResponse.statusCode))")
                if(httpResponse.statusCode == 200) {
                    print("Request success.")
                } else {
                    print("Request failed.")
                }
            } else {
                print(error ?? "Response is malformed.")
            }
        }
        task.resume()
    }
    private init() {
    }
}

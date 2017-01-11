//
//  AldoEncoding.swift
//  Pods
//
//  Created by Team Aldo on 11/01/2017.
//
//

import Foundation
import Alamofire

struct AldoEncoding: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        guard let parameters = parameters else { return urlRequest }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            urlRequest.httpBody = data
        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }
        
        return urlRequest
    }
}

//
//  AldoEncoding.swift
//  Pods
//
//  Created by Team Aldo on 11/01/2017.
//
//
import Foundation
import Alamofire

/**
    Encoding the information that is passed in the body when a request
    is send to the server runinng the Aldo Framework. This struct is a fix
    for a problem that occurs when using the **JSONEncoding** struct of **Alamofire**.
    **The code in this struct is a combination of JSONEncoding.default
    and URLEncoding implemented by Alamofire.**
 
    For more information about these structs, see
    [Alamofire](https://github.com/Alamofire/Alamofire).
 */
public struct AldoEncoding: ParameterEncoding {

    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()

        if urlRequest.httpMethod != HTTPMethod.get.rawValue {

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
        }
        return urlRequest
    }
}

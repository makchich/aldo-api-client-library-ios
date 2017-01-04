//
//  Callback.swift
//  Pods
//
//  Created by Team Aldo on 29/12/2016.
//
//

import Foundation

public protocol Callback {
    
    func onResponse(responseCode: Int, response: NSDictionary)
    
}

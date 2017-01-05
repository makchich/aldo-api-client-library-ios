//
//  ViewController.swift
//  Aldo
//
//  Created by makchich on 01/03/2017.
//  Copyright (c) 2017 makchich. All rights reserved.
//

import UIKit
import Aldo

class ViewController: UIViewController, Callback {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Aldo.setHostAddress(address: "https://expeditionmundus.herokuapp.com")
        
        if !Aldo.hasAuthToken() {
            Aldo.requestAuthToken(callback: self)
        }
        
        if !Aldo.hasSession() {
            Aldo.createSession(username: "aldo_demo", callback: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onResponse(responseCode: Int, response: NSDictionary) {
        // Do Nothing
        
        print(responseCode)
        print(response)
    }

}


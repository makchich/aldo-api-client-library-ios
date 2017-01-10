//
//  ViewController.swift
//  Aldo
//
//  Created by makchich on 01/03/2017.
//  Copyright (c) 2017 makchich. All rights reserved.
//

import UIKit
import Aldo

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Aldo.setHostAddress(address: "https://expeditionmundus.herokuapp.com")
        
        if !Aldo.hasAuthToken() {
            Aldo.requestAuthToken()
        }
        
        if !Aldo.hasSession() {
            Aldo.createSession(username: "aldo_demo")
        }
    }

}


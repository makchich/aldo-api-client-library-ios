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
        Aldo.requestAuthToken(callback: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onResponse(responseCode: Int, response: NSDictionary) {
        // Do Nothing
    }

}


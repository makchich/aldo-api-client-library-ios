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
        
        let username: String = "iPhone_Simulator"
        
        Aldo.setHostAddress(address: "127.0.0.1")
        Aldo.requestAuthToken()
        Aldo.createSession(username: username)
        Aldo.joinSession(username: username, token: "token")
        Aldo.requestSessionInfo()
        Aldo.requestSessionPlayers()
        Aldo.changeSessionState(newState: AldoSession.State.PAUSE)
        Aldo.deleteSession()
        Aldo.requestPlayerInfo()
        Aldo.requestDevicePlayers()
        Aldo.updateUsername(username: "iPhone_Simulator_update")
    }

}


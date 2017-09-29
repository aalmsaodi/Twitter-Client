//
//  ViewController.swift
//  Twitter Client
//
//  Created by user on 9/26/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit
import AFNetworking
import BDBOAuth1Manager

class LoginVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func loginTapped(_ sender: Any) {
        
        TwitterClient.shared?.login()
    }
}


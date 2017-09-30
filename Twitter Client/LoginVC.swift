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
    
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.layer.cornerRadius = loginBtn.bounds.height/2
        loginBtn.layer.masksToBounds = true
    }

    @IBAction func loginTapped(_ sender: Any) {
        TwitterClient.shared?.login()
    }
}


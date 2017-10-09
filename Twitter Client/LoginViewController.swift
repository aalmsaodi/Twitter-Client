//
//  LoginViewController.swift
//  Twitter Client
//
//  Created by user on 9/26/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit
import AFNetworking
import BDBOAuth1Manager

class LoginViewController: UIViewController {
  
  @IBOutlet weak private var loginBtn: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loginBtn.layer.cornerRadius = loginBtn.bounds.height/2
    loginBtn.layer.masksToBounds = true
  }
  
  @IBAction private func loginTapped(_ sender: Any) {
    TwitterClient.shared?.login()
  }
}


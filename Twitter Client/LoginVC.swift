//
//  ViewController.swift
//  Twitter Client
//
//  Created by user on 9/26/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func loginTapped(_ sender: Any) {
        TwitterClient.shared.login(success: {
            self.performSegue(withIdentifier: "fromLogin", sender: nil)
        }) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}


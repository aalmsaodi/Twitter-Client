//
//  ProfileViewController.swift
//  Twitter Client
//
//  Created by user on 10/3/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

  @IBOutlet weak var backgroundImage: UIImageView!
  @IBOutlet weak var avatarImage: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var screenNameLabel: UILabel!
  @IBOutlet weak var tweetsCountLabel: UILabel!
  @IBOutlet weak var followingsCountLabel: UILabel!
  @IBOutlet weak var followersCountLabel: UILabel!
  @IBOutlet weak var tabelView: UITableView!
  @IBOutlet weak var profileContentTopConstraint: NSLayoutConstraint!
  
  var user:User!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
//      if let urlString = user.backgroundUrl, let url = URL(string: urlString) {
//        backgroundImage.setImageWith(url)
//      }
      if let url = URL(string: user.avatarImageUrl) {
        avatarImage.setImageWith(url)
        avatarImage.layer.cornerRadius = 5.0
        avatarImage.layer.masksToBounds = true
      }
      usernameLabel.text = user.name
      screenNameLabel.text = user.screenName
//      tweetsCountLabel.text = String(user.tweetsCount)
//      followersCountLabel.text = String(user.followersCount)
//      followingsCountLabel.text = String(user.followingsCount)
    }
  
  

}

//
//  ProfileInfoCell.swift
//  Twitter Client
//
//  Created by user on 10/6/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class ProfileInfoCell: UITableViewCell {
  
  @IBOutlet weak var avatarImage: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var screenNameLabel: UILabel!
  @IBOutlet weak var tweetsCountLabel: UILabel!
  @IBOutlet weak var followingsCountLabel: UILabel!
  @IBOutlet weak var followersCountLabel: UILabel!
  @IBOutlet weak var profileInfoView: UIView!
  @IBOutlet weak var statesPage: UIView!
  @IBOutlet weak var descriptionPage: UIView!
  
  var user:User! {
    didSet {
      if let url = URL(string: user.avatarImageUrl) {
        avatarImage.setImageWith(url)
        avatarImage.layer.cornerRadius = 5.0
        avatarImage.layer.masksToBounds = true
      }
      usernameLabel.text = user.name
      screenNameLabel.text = "@\(user.screenName)"
      descriptionLabel.text = user.userDescription
      tweetsCountLabel.text = String(describing: user.tweetsCount)
      followersCountLabel.text = String(describing: user.followersCount)
      followingsCountLabel.text = String(describing: user.followingsCount)
    }
  }
  
  var changingAvatarImageSizeBy: CGFloat? {
    didSet {
      avatarImage.frame.size.height += changingAvatarImageSizeBy!
      avatarImage.frame.size.width += changingAvatarImageSizeBy!
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  @IBAction func onProfilePageControl(_ sender: UIPageControl) {
    if sender.currentPage == 0 {
      descriptionPage.isHidden = true
      statesPage.isHidden = false
    } else {
      descriptionPage.isHidden = false
      statesPage.isHidden = true
    }
  }
  
}

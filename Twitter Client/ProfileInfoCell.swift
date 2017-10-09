//
//  ProfileInfoCell.swift
//  Twitter Client
//
//  Created by user on 10/6/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class ProfileInfoCell: UITableViewCell {
  
  @IBOutlet weak private var avatarImageBtn: UIButton!
  @IBOutlet weak private var usernameLabel: UILabel!
  @IBOutlet weak private var descriptionLabel: UILabel!
  @IBOutlet weak private var screenNameLabel: UILabel!
  @IBOutlet weak private var tweetsCountLabel: UILabel!
  @IBOutlet weak private var followingsCountLabel: UILabel!
  @IBOutlet weak private var followersCountLabel: UILabel!
  @IBOutlet weak private var statesPage: UIView!
  @IBOutlet weak private var descriptionPage: UIView!
  
  var isDescriptionCurrentPage:((Bool)->())?
  var takePicForProfileAvatar:(()->())?

  var user:User! {
    didSet {
      if let url = URL(string: user.avatarImageUrl) {
        avatarImageBtn.setImageFor(.normal, with: url)
        avatarImageBtn.layer.cornerRadius = 5.0
        avatarImageBtn.layer.masksToBounds = true
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
      if case 90..<121 = Int(changingAvatarImageSizeBy!) {
        avatarImageBtn.transform = CGAffineTransform(scaleX: (changingAvatarImageSizeBy!-40)/80, y: (changingAvatarImageSizeBy!-40)/80)
        avatarImageBtn.frame.origin.x = 20 - (120 - changingAvatarImageSizeBy!)/4
      }
    }
  }
  
  @IBAction private func onProfilePageControl(_ sender: UIPageControl) {
    if sender.currentPage == 0 { //states page
      descriptionPage.isHidden = true
      statesPage.isHidden = false
      isDescriptionCurrentPage?(false)
    } else {                    //description page
      descriptionPage.isHidden = false
      statesPage.isHidden = true
      isDescriptionCurrentPage?(true)
    }
  }
  
  @IBAction private func onAvatarImageBtn(_ sender: Any) {
    takePicForProfileAvatar?()
  }
}

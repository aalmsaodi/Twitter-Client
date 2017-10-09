//
//  AccountCell.swift
//  Twitter Client
//
//  Created by user on 10/6/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class AccountCell: UITableViewCell {
  
  @IBOutlet weak private var accountView: UIView!
  @IBOutlet weak private var userNameLabel: UILabel!
  @IBOutlet weak private var screenNameLabel: UILabel!
  @IBOutlet weak private var avatarImage: UIImageView!
  
  private var originalAlpha: CGFloat!
  private var originalScale: CGFloat!
  private var originalPositionX: CGFloat!
  
  var user:User! {
    didSet {
      if let url = URL(string: user.avatarImageUrl) {
        avatarImage.setImageWith(url)
        avatarImage.layer.cornerRadius = 5.0
        avatarImage.layer.masksToBounds = true
      }
      userNameLabel.text = user.name
      screenNameLabel.text = "@\(user.screenName)"
      
      //Reset accountView to original state to cancel dequeuing effect
      accountView.frame.origin.x = 0
      accountView.transform = CGAffineTransform(scaleX: 1, y: 1)
      accountView.alpha = 1
    }
  }
  
  func animateAccountView(_ sender: UIPanGestureRecognizer, removeCell: @escaping ()->() ) {
    let translation = sender.translation(in: contentView).x
    let velocity = sender.velocity(in: contentView).x
    
    if sender.state == .began {
      originalAlpha = accountView.alpha
      originalScale = accountView.transform.tx
      originalPositionX = accountView.frame.origin.x
      
    } else if sender.state == UIGestureRecognizerState.changed {
      if originalPositionX + translation > 0 {
        accountView.frame.origin.x = originalPositionX + translation
        accountView.transform = CGAffineTransform(scaleX: (500 - translation)/500, y: (500 - translation)/500)
        accountView.alpha = (500 - translation)/500
      }
    } else if sender.state == .ended {
      UIView.animate(withDuration: 0.5, animations: {
        if abs(self.accountView.frame.origin.x - self.originalPositionX) > 70 {
          if velocity > 0 {   //finish Auto-removing accoutn
            self.accountView.frame.origin.x = self.accountView.frame.width
            self.accountView.transform = CGAffineTransform(scaleX: 2/5, y: 2/5)
            self.accountView.alpha = 0.7
            removeCell()
          } else {            //cancel removing account
            self.accountView.frame.origin.x = 0
            self.accountView.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.accountView.alpha = 1
          }
        } else {              //failed removing account
          self.accountView.frame.origin.x = 0
          self.accountView.transform = CGAffineTransform(scaleX: 1, y: 1)
          self.accountView.alpha = 1
        }
      })
    }
  }
}

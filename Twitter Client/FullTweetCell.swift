//
//  FullTweetCell.swift
//  Twitter Client
//
//  Created by user on 9/26/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit
import AFNetworking

class FullTweetCell: UITableViewCell {

    @IBOutlet weak private var didRetweetedImage: UIImageView!
    @IBOutlet weak private var didRetweetedText: UILabel!
    @IBOutlet weak private var avatarImage: UIImageView!
    @IBOutlet weak private var avatarImageVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak private var userNameLabel: UILabel!
    @IBOutlet weak private var userLinkLabel: UILabel!
    @IBOutlet weak private var tweetTimeLabel: UILabel!
    @IBOutlet weak private var tweetTextLabel: UILabel!
    @IBOutlet weak private var retweetBtn: UIButton!
    @IBOutlet weak private var favorBtn: UIButton!
    @IBOutlet weak var replyBtn: UIButton! //public to set its tag value
    
    var tweet:Tweet! {
        didSet{
            if let url = URL(string: tweet.user.avatarImageUrl) {
                avatarImage.setImageWith(url)
                avatarImage.layer.cornerRadius = 5.0
                avatarImage.layer.masksToBounds = true
            }
            userNameLabel.text = tweet.user.name
            userLinkLabel.text = tweet.user.screenName
            tweetTextLabel.text = tweet.tweetText
            tweetTimeLabel.text = tweet.tweetAge
            
            if tweet.isFavoritedBtn {
                favorBtn.imageView?.image = UIImage(named: "favor-icon-red")
            }  else {
                favorBtn.imageView?.image = UIImage(named: "favor-icon")
            }
            
            if tweet.isRetweetedBtn {
                retweetBtn.imageView?.image = UIImage(named: "retweet-icon-green")
            } else {
                retweetBtn.imageView?.image = UIImage(named: "retweet-icon")
            }
            
            if let retweetedBy = tweet.retweetedBy?["name"] {
                didRetweetedText.text = "\(retweetedBy) retweeted"
                didRetweetedImage.isHidden = false
                didRetweetedText.isHidden = false
                avatarImageVerticalConstraint.constant = didRetweetedImage.bounds.height
            } else {
                didRetweetedImage.isHidden = true
                didRetweetedText.isHidden = true
                avatarImageVerticalConstraint.constant = 5
            }
        }
    }
    
    @IBAction private func onRetweetBtn(_ sender: Any) {
        if tweet.isRetweetedBtn {
            tweet.unretweet() {error in
                if error == nil {
                    self.retweetBtn.imageView?.image = UIImage(named: "retweet-icon")
                }
            }
        } else {
            tweet.retweet() {error in
                if error == nil {
                    self.retweetBtn.imageView?.image = UIImage(named: "retweet-icon-green")
                }
            }
        }
    }
    
    @IBAction private func onFavorBtn(_ sender: Any) {
        if tweet.isFavoritedBtn {
            tweet.unfavorite() { error in
                if error == nil {
                    self.favorBtn.imageView?.image = UIImage(named: "favor-icon")
                }
            }
        } else {
            tweet.favorite() { error in
                if error == nil {
                    self.favorBtn.imageView?.image = UIImage(named: "favor-icon-red")
                }
            }
        }
    }
}

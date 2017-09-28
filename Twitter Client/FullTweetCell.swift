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

    @IBOutlet weak var didRetweetedImage: UIImageView!
    @IBOutlet weak var didRetweetedText: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLinkLabel: UILabel!
    @IBOutlet weak var tweetTimeLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!

    @IBOutlet weak var replyBtn: UIButton!
    
    @IBOutlet weak var retweetBtn: UIButton!
    
    @IBOutlet weak var favorBtn: UIButton!
    
    
    var tweet:Tweet! {
        didSet{
            if let url = URL(string: tweet.user.avatarImageUrl) {
                avatarImage.setImageWith(url)
            }
            userNameLabel.text = tweet.user.name
            userLinkLabel.text = tweet.user.screenName
            
            tweetTextLabel.text = tweet.tweetText
            
            tweetTimeLabel.text = tweet.tweetAge
            
            if let favorite = tweet.favoritedBtn, favorite {
                favorBtn.setImage(UIImage(named: "favor-icon-red"), for: UIControlState.normal)
            }
            if tweet.retweetedBtn {
                retweetBtn.setImage(UIImage(named: "retweet-icon-red"), for: UIControlState.normal)
            }
        }
    }

    @IBAction func replyBtnTapped(_ sender: Any) {
    }
    @IBAction func retweetBtnTapped(_ sender: Any) {
    }
    @IBAction func favorBtnTapped(_ sender: Any) {
    }
}

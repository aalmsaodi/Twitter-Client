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
    @IBOutlet weak var avatarImageVerticalConstraint: NSLayoutConstraint!
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
            
            if tweet.favoritedBtn {
                favorBtn.imageView?.image = UIImage(named: "favor-icon-red")
            }  else {
                favorBtn.imageView?.image = UIImage(named: "favor-icon")
            }

            if tweet.retweetedBtn {
                retweetBtn.imageView?.image = UIImage(named: "retweet-icon-red")
            } else {
                retweetBtn.imageView?.image = UIImage(named: "retweet-icon")
            }
            
            if let retweetedBy = tweet.retweetedBy {
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

    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImage.layer.cornerRadius = 5.0
        avatarImage.layer.masksToBounds = true
    }
    
    @IBAction func retweetBtnTapped(_ sender: Any) {
        if tweet.retweetedBtn {
            TwitterClient.shared?.retweetIt(id: tweet.id, completion: { (error: Error?) in
                if error == nil {
                    self.tweet.retweetedBtn = false
                    self.retweetBtn.imageView?.image = UIImage(named: "retweet-icon")
                }
            })
        } else {
            TwitterClient.shared?.retweetIt(id: tweet.id, completion: { (error: Error?) in
                if error == nil {
                    self.tweet.retweetedBtn = true
                    self.retweetBtn.imageView?.image = UIImage(named: "retweet-icon-green")
                }
            })
        }
    }
    
    @IBAction func favorBtnTapped(_ sender: Any) {
        if tweet.favoritedBtn {
            TwitterClient.shared?.destroyFavorite(id: tweet.id, completion: { error in
                if error == nil {
                    self.tweet.favoritedBtn = false
                    self.favorBtn.imageView?.image = UIImage(named: "favor-icon")
                }
            })
        } else {
            TwitterClient.shared?.createFavorite(id: tweet.id, completion: { error in
                if error == nil {
                    self.tweet.favoritedBtn = true
                    self.favorBtn.imageView?.image = UIImage(named: "favor-icon-red")
                }
            })
        }
    }
}

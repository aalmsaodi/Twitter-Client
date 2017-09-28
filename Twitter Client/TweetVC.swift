//
//  TweetVC.swift
//  Twitter Client
//
//  Created by user on 9/28/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class TweetVC: UIViewController {

    @IBOutlet weak var retweetedByImage: UIImageView!
    @IBOutlet weak var retweetedByLabel: UILabel!
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!

    @IBOutlet weak var creationDateLabel: UILabel!
    
    @IBOutlet weak var numRetweetsLabel: UILabel!
    @IBOutlet weak var numFavoritsLabel: UILabel!
    
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var retweetBtn: UIButton!
    @IBOutlet weak var favorBtn: UIButton!
    
    var tweet:Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: tweet.user.avatarImageUrl) {
            avatarImage.setImageWith(url)
        }
        userNameLabel.text = tweet.user.name
        screenNameLabel.text = tweet.user.screenName
        
        tweetTextLabel.text = tweet.tweetText
        
        creationDateLabel.text = tweet.creationDate
        
        if let favorite = tweet.favoritedBtn, favorite {
            favorBtn.setImage(UIImage(named: "favor-icon-red"), for: UIControlState.normal)
        }
        if tweet.retweetedBtn {
            retweetBtn.setImage(UIImage(named: "retweet-icon-red"), for: UIControlState.normal)
        }
    }

    @IBAction func replyBtnTapped(_ sender: Any) {
    }
    @IBAction func retweetBtnTapped(_ sender: Any) {
    }
    @IBAction func favorBtnTapped(_ sender: Any) {
    }
}

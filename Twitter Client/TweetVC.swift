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
    @IBOutlet weak var avatarImageVerticalConstraint: NSLayoutConstraint!
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
        
        if tweet.favoritedBtn {
            favorBtn.imageView?.image = UIImage(named: "favor-icon-red")
        }
        
        if tweet.retweetedBtn {
            retweetBtn.imageView?.image = UIImage(named: "retweet-icon-red")
        }
        
        numRetweetsLabel.text = "\(tweet.retweetCount)"
        
        if let retweetedBy = tweet.retweetedBy {
            retweetedByLabel.text = "\(retweetedBy) retweeted"
        } else {
            retweetedByImage.isHidden = true
            retweetedByLabel.isHidden = true
            avatarImageVerticalConstraint.constant -= retweetedByImage.bounds.height
        }
    }

    @IBAction func replyBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "fromReplyBtnOnTweetVCToPostTweetVC", sender: self)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let postTweetVC = segue.destination as! PostTweetVC
            postTweetVC.retweeting = true
            postTweetVC.replyToTweetID = tweet.id
            postTweetVC.ownerOfTweet = tweet.user.screenName

    }
    
}

//
//  TweetViewController.swift
//  Twitter Client
//
//  Created by user on 9/28/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController {
  
  @IBOutlet weak private var retweetedByImage: UIImageView!
  @IBOutlet weak private var retweetedByLabel: UILabel!
  @IBOutlet weak private var avatarImage: UIImageView!
  @IBOutlet weak private var avatarImageVerticalConstraint: NSLayoutConstraint!
  @IBOutlet weak private var userNameLabel: UILabel!
  @IBOutlet weak private var screenNameLabel: UILabel!
  @IBOutlet weak private var tweetTextLabel: UILabel!
  @IBOutlet weak private var creationDateLabel: UILabel!
  @IBOutlet weak private var numRetweetsLabel: UILabel!
  @IBOutlet weak private var numFavoritsLabel: UILabel!
  @IBOutlet weak private var replyBtn: UIButton!
  @IBOutlet weak private var retweetBtn: UIButton!
  @IBOutlet weak private var favorBtn: UIButton!
  
  var tweet:Tweet!
  var returningNewTweet: ((Tweet?)->())?
  var returnCurrentStatesOfRetweetAndFavorBtns: ((Bool, Bool)->())?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let url = URL(string: tweet.user.avatarImageUrl) {
      avatarImage.setImageWith(url)
      avatarImage.layer.cornerRadius = 5.0
      avatarImage.layer.masksToBounds = true
    }
    userNameLabel.text = tweet.user.name
    screenNameLabel.text = tweet.user.screenName
    tweetTextLabel.text = tweet.tweetText
    creationDateLabel.text = tweet.creationDate
    numFavoritsLabel.text = "\(tweet.favoriteCount)"
    numRetweetsLabel.text = "\(tweet.retweetCount)"
    
    if tweet.isFavoritedBtn {
      favorBtn.imageView?.image = UIImage(named: "favor-icon-red")
    }
    
    if tweet.isRetweetedBtn {
      retweetBtn.imageView?.image = UIImage(named: "retweet-icon-green")
    } else {
      retweetBtn.imageView?.image = UIImage(named: "retweet-icon")
    }
    
    if let retweetedBy = tweet.retweetedBy?["name"] {
      retweetedByLabel.text = "\(retweetedBy) retweeted"
    } else {
      retweetedByImage.isHidden = true
      retweetedByLabel.isHidden = true
      avatarImageVerticalConstraint.constant -= retweetedByImage.bounds.height
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    returnCurrentStatesOfRetweetAndFavorBtns!(tweet.isRetweetedBtn, tweet.isFavoritedBtn)
  }
  
  @IBAction private func onReplyBtn(_ sender: Any) {
    performSegue(withIdentifier: "fromReplyBtnOnTweetVCToPostTweetVC", sender: self)
  }
  
  @IBAction private func onRetweetBtn(_ sender: Any) {
    if tweet.isRetweetedBtn {
      tweet.unretweet() {error in
        if error == nil {
          self.numRetweetsLabel.text = String(self.tweet.retweetCount)
          self.retweetBtn.imageView?.image = UIImage(named: "retweet-icon")
        }
      }
    } else {
      tweet.retweet() {error in
        if error == nil {
          self.numRetweetsLabel.text = String(self.tweet.retweetCount)
          self.retweetBtn.imageView?.image = UIImage(named: "retweet-icon-green")
        }
      }
    }
  }
  
  @IBAction private func onFavorBtn(_ sender: Any) {
    if tweet.isFavoritedBtn {
      tweet.unfavorite() { error in
        if error == nil {
          self.numFavoritsLabel.text = String(self.tweet.favoriteCount)
          self.favorBtn.imageView?.image = UIImage(named: "favor-icon")
        }
      }
    } else {
      tweet.favorite() { error in
        if error == nil {
          self.numFavoritsLabel.text = String(self.tweet.favoriteCount)
          self.favorBtn.imageView?.image = UIImage(named: "favor-icon-red")
        }
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let postTweetViewController = segue.destination as! PostTweetViewController
    postTweetViewController.retweeting = true
    postTweetViewController.tweetReplyingTo = tweet
    postTweetViewController.returningNewTweet = {[unowned self] tweet in
      if let newTweet = tweet {
        self.returningNewTweet!(newTweet)
      }
    }
  }
  
}

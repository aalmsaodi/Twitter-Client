//
//  PostTweetViewController.swift
//  Twitter Client
//
//  Created by user on 9/28/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit
import MRProgress

class PostTweetViewController: UIViewController, UITextViewDelegate {
  
  @IBOutlet weak private var avatarImage: UIImageView!
  @IBOutlet weak private var userNameLabel: UILabel!
  @IBOutlet weak private var screenNameLabel: UILabel!
  @IBOutlet weak private var tweetTextField: UITextView!
  private let TWEETLENGTHLIMIT:Int = 140
  private var counterLabel:UILabel!

  var retweeting:Bool = false
  var tweetReplyingTo:Tweet?
  var returningNewTweet: ((Tweet?)->())?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tweetTextField.delegate = self
    tweetTextField.becomeFirstResponder()
    if let url = URL(string: TwitterClient.currentAccount.user.avatarImageUrl) {
      avatarImage.setImageWith(url)
    }
    userNameLabel.text = TwitterClient.currentAccount.user.name
    screenNameLabel.text = "@\(TwitterClient.currentAccount.user.screenName)"
    
    if let navigationBar = navigationController?.navigationBar {
      counterLabel = UILabel()
      let frame = CGRect(x: 4*navigationBar.frame.width/6, y: 0, width: 50, height: navigationBar.frame.height)
      counterLabel = UILabel(frame: frame)
      counterLabel.textColor = UIColor.lightGray
      navigationBar.addSubview(counterLabel)
      counterLabel.text = String(TWEETLENGTHLIMIT)
      navigationBar.tintColor = .gray
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.navigationBar.tintColor = UIColor.gray
  }
  
  @IBAction private func onCancelBtn(_ sender: Any) {
    counterLabel.text = ""
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction private func onTweetBtn(_ sender: Any) {
    guard  let tweet = tweetTextField.text else {return}
    self.tweetTextField.resignFirstResponder()
    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissCheckView))
    tap.delegate = self as? UIGestureRecognizerDelegate
    
    if retweeting { //****************** Replying to Tweet ***********************
      TwitterClient.shared?.postTweet(tweet: tweet, replyToTweetID: tweetReplyingTo?.id, ownerOfTweet: "@\(tweetReplyingTo!.user.screenName)") { [unowned self] (error, newTweetID) in
        if error == nil {
          MRProgressOverlayView.showOverlayAdded(to: self.view, title: "Reply Sent", mode: .checkmark, animated: true)
          self.createTempTweetWithoutFetching(itIsNewTweet: false, newTweetID: newTweetID!)
        } else {
          MRProgressOverlayView.showOverlayAdded(to: self.view, title: "Replying Faild", mode: .cross, animated: true)
          print(error ?? "tweet didn't get through")
        }
        self.view.addGestureRecognizer(tap)
      }
      
    } else { //****************** Posting new Tweet ***********************
      TwitterClient.shared?.postTweet(tweet: tweet, replyToTweetID: nil, ownerOfTweet: nil) { [unowned self] (error, newTweetID) in
        if error == nil {
          MRProgressOverlayView.showOverlayAdded(to: self.view, title: "Tweet Sent", mode: .checkmark, animated: true)
          self.createTempTweetWithoutFetching(itIsNewTweet: true, newTweetID: newTweetID!)
        } else {
          MRProgressOverlayView.showOverlayAdded(to: self.view, title: "Tweeting Faild", mode: .cross, animated: true)
          print(error ?? "tweet didn't get through")
        }
        self.view.addGestureRecognizer(tap)
      }
    }
  }
  
  @objc private func dismissCheckView() {
    MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
    counterLabel.text = ""
    navigationController?.popViewController(animated: true)
  }
  
  private func createTempTweetWithoutFetching(itIsNewTweet:Bool, newTweetID:String){
    var tweetText:String!
    var retweetedBy:String?
    if itIsNewTweet {
      tweetText = tweetTextField.text!
    } else {
      let replayingToScreen = "@\((tweetReplyingTo?.user.screenName)!)"
      tweetText = "\(replayingToScreen) \(tweetTextField.text!)"
      retweetedBy = tweetReplyingTo?.retweetedBy?["name"]
    }
    let formatter = DateFormatter()
    formatter.dateFormat = "E M d HH:mm:ss Z y"
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    let creationDate = formatter.string(from: Date())
    let tweetAge = "0s"
    
    let newTweet = Tweet(id: newTweetID, user: (TwitterClient.currentAccount.user)!, tweetText: tweetText, creationDate: creationDate, tweetAge: tweetAge, retweetedBy: retweetedBy)
    
    returningNewTweet?(newTweet)
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let newLength = textView.text!.characters.count + (text.characters.count - range.length)
    counterLabel.text = String(TWEETLENGTHLIMIT - newLength)
    
    return newLength < TWEETLENGTHLIMIT
  }
}

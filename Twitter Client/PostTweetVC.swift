//
//  PostTweetVC.swift
//  Twitter Client
//
//  Created by user on 9/28/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit
import MRProgress

class PostTweetVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextField: UITextView!
    
    var retweeting:Bool!
    var counterLabel:UILabel!
    var tweetReplyingTo:Tweet?
    let TWEETLENGTHLIMIT:Int = 140
    var returningNewTweet: ((Tweet?)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetTextField.delegate = self
        tweetTextField.becomeFirstResponder()
        if let url = URL(string: TwitterClient.loggedInUser.avatarImageUrl) {
            avatarImage.setImageWith(url)
        }
        userNameLabel.text = TwitterClient.loggedInUser.name
        screenNameLabel.text = TwitterClient.loggedInUser.screenName
        navigationController?.navigationBar.backgroundColor = UIColor.lightGray
        
        if let navigationBar = self.navigationController?.navigationBar {
            let frame = CGRect(x: 3*navigationBar.frame.width/5, y: 0, width: 50, height: navigationBar.frame.height)
            counterLabel = UILabel(frame: frame)
            counterLabel.textColor = UIColor.white
            navigationBar.addSubview(counterLabel)
            counterLabel.text = String(TWEETLENGTHLIMIT)
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        counterLabel.text = ""
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tweetTapped(_ sender: Any) {
        guard  let tweet = tweetTextField.text else {return}
        self.tweetTextField.resignFirstResponder()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissCheckView))
        tap.delegate = self as? UIGestureRecognizerDelegate
        
        if retweeting { //Replying to a Tweet
            TwitterClient.shared?.postTweet(tweet: tweet, replyToTweetID: tweetReplyingTo?.id, ownerOfTweet: tweetReplyingTo?.user.screenName) { [unowned self] (error, newTweetID) in
                if error == nil {
                    MRProgressOverlayView.showOverlayAdded(to: self.view, title: "Reply Sent", mode: .checkmark, animated: true)
                    self.createTempTweetToShowOnTimeLineWithoutFetching(itIsNewTweet: false, newTweetID: newTweetID!)
                } else {
                    MRProgressOverlayView.showOverlayAdded(to: self.view, title: "Replying Faild", mode: .cross, animated: true)
                    print(error ?? "tweet didn't get through")
                }
                self.view.addGestureRecognizer(tap)
            }
            
        } else { //Posting new Tweet
            TwitterClient.shared?.postTweet(tweet: tweet, replyToTweetID: nil, ownerOfTweet: nil) { [unowned self] (error, newTweetID) in
                if error == nil {
                    MRProgressOverlayView.showOverlayAdded(to: self.view, title: "Tweet Sent", mode: .checkmark, animated: true)
                    self.createTempTweetToShowOnTimeLineWithoutFetching(itIsNewTweet: true, newTweetID: newTweetID!)
                } else {
                    MRProgressOverlayView.showOverlayAdded(to: self.view, title: "Tweeting Faild", mode: .cross, animated: true)
                    print(error ?? "tweet didn't get through")
                }
                self.view.addGestureRecognizer(tap)
            }
        }
    }
    
    func dismissCheckView() {
        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
        counterLabel.text = ""
        navigationController?.popViewController(animated: true)
    }
    
    func createTempTweetToShowOnTimeLineWithoutFetching(itIsNewTweet:Bool, newTweetID:String){
        var tweetText:String!
        var retweetedBy:String?
        if itIsNewTweet {
            tweetText = tweetTextField.text!
        } else {
            let replayingToScreen = (tweetReplyingTo?.user.screenName)!
            tweetText = "\(replayingToScreen) \(tweetTextField.text!)"
            retweetedBy = tweetReplyingTo?.retweetedBy?["name"]
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "E M d HH:mm:ss Z y"
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let creationDate = formatter.string(from: Date())
        let tweetAge = "0s"
        
        let newTweet = Tweet(id: newTweetID, user: (TwitterClient.loggedInUser)!, tweetText: tweetText, creationDate: creationDate, tweetAge: tweetAge, retweetedBy: retweetedBy)
        
        returningNewTweet?(newTweet)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text!.characters.count + (text.characters.count - range.length)
        counterLabel.text = String(TWEETLENGTHLIMIT - newLength)
        
        return newLength < TWEETLENGTHLIMIT
    }
}

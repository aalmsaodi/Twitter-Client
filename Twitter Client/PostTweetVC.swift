//
//  PostTweetVC.swift
//  Twitter Client
//
//  Created by user on 9/28/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class PostTweetVC: UIViewController {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextField: UITextField!
    
    var retweeting:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let url = URL(string: loggedInUser.avatarImageUrl) {
            avatarImage.setImageWith(url)
        }
        
        userNameLabel.text = loggedInUser.name
        screenNameLabel.text = loggedInUser.screenName
        
        navigationController?.navigationBar.backgroundColor = UIColor.lightGray
    }

    @IBAction func cancelTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func tweetTapped(_ sender: Any) {
        guard  let tweet = tweetTextField.text else {return}
        TwitterClient.shared.postNewTweet(tweet: tweet) { (error) in
            if error == nil {
                self.navigationController?.popViewController(animated: true)
            } else {
                print(error ?? "tweet didn't get through")
            }
        }
    }
    
   
}

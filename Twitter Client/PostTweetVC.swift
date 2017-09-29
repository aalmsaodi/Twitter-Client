//
//  PostTweetVC.swift
//  Twitter Client
//
//  Created by user on 9/28/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class PostTweetVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextField: UITextField!
    
    var retweeting:Bool!
    var counterLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let url = URL(string: TwitterClient.loggedInUser.avatarImageUrl) {
            avatarImage.setImageWith(url)
        }
        
        userNameLabel.text = TwitterClient.loggedInUser.name
        screenNameLabel.text = TwitterClient.loggedInUser.screenName
        
        navigationController?.navigationBar.backgroundColor = UIColor.lightGray
//        navigationItem.
    }

    @IBAction func cancelTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func tweetTapped(_ sender: Any) {
        guard  let tweet = tweetTextField.text else {return}
        TwitterClient.shared?.postNewTweet(tweet: tweet) { (error) in
            if error == nil {
                self.navigationController?.popViewController(animated: true)
            } else {
                print(error ?? "tweet didn't get through")
            }
        }
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let newLength = ((textField.text?.utf16)?.count)! + (string.utf16).count - range.length
//        if(newLength <= 140){
//            self.label.text = "\(140 - newLength)"
//            return true
//        }else{
//            return false
//        }
//    }
   
}

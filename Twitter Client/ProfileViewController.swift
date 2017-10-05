//
//  ProfileViewController.swift
//  Twitter Client
//
//  Created by user on 10/3/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
  
  @IBOutlet weak var backgroundImage: UIImageView!
  @IBOutlet weak var avatarImage: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var screenNameLabel: UILabel!
  @IBOutlet weak var tweetsCountLabel: UILabel!
  @IBOutlet weak var followingsCountLabel: UILabel!
  @IBOutlet weak var followersCountLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var profileContentTopConstraint: NSLayoutConstraint!
  
  var user:User!
  var tweets:[Tweet]=[]
  
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.delegate = self
    tableView.dataSource = self
    tableView.estimatedRowHeight = 200
    tableView.rowHeight = UITableViewAutomaticDimension
    
    if let urlString = user.backgroundUrl, let url = URL(string: urlString) {
      backgroundImage.setImageWith(url)
    }
    if let url = URL(string: user.avatarImageUrl) {
      avatarImage.setImageWith(url)
      avatarImage.layer.cornerRadius = 5.0
      avatarImage.layer.masksToBounds = true
    }
    usernameLabel.text = user.name
    screenNameLabel.text = user.screenName
    tweetsCountLabel.text = String(describing: user.tweetsCount)
    followersCountLabel.text = String(describing: user.followersCount)
    followingsCountLabel.text = String(describing: user.followingsCount)
    
    TwitterClient.shared?.getHomeTimeLine(offset: nil) { (tweets, error) in
      if let tweets = tweets {
        self.tweets = tweets
        self.tableView.reloadData()
      } else if let error = error {
        print("Error getting home timeline: " + error.localizedDescription)
      }
    }
  }
}


extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tweets.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "fullTweetCell", for: indexPath) as? FullTweetCell else { return UITableViewCell()}
    cell.tweet = tweets[indexPath.row]
    cell.replyBtn.tag = indexPath.row
    return cell
  }
}

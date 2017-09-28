//
//  HomeVC.swift
//  
//
//  Created by user on 9/27/17.
//
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var tweets:[Tweet] = []
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        TwitterClient.shared.getHomeTimeLine { (tweets, error) in
            if let tweets = tweets {
                self.tweets = tweets
                self.tableView.reloadData()
            } else if let error = error {
                print("Error getting home timeline: " + error.localizedDescription)
            }
        }
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        TwitterClient.shared.logout()
        navigationController?.popViewController(animated: true)
    }
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        TwitterClient.shared.getHomeTimeLine { (tweets, error) in
            if let tweets = tweets {
                self.tweets = tweets
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            } else if let error = error {
                print("Error getting home timeline: " + error.localizedDescription)
            }
        }
        
    }

}


extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "fullTweetCell") as? FullTweetCell else {return UITableViewCell()}
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toTweetVC" {
            let tweetVC = segue.destination as! TweetVC
            let index = tableView.indexPath(for: sender as! FullTweetCell)
            tweetVC.tweet = tweets[(index?.row)!]
        } else if segue.identifier == "toPostNewTweet" {
            
        } else if segue.identifier == "toReplyToTweet" {
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FullTweetCell
        performSegue(withIdentifier: "toTweetVC", sender: cell)
    }
}

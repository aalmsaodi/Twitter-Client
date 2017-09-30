//
//  HomeVC+TableView.swift
//  Twitter Client
//
//  Created by user on 9/29/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "fullTweetCell") as? FullTweetCell else {return UITableViewCell()}
        cell.tweet = tweets[indexPath.row]
        cell.replyBtn.tag = indexPath.row
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromCellToTweetVC" {
            let tweetVC = segue.destination as! TweetVC
            let index = tableView.indexPath(for: sender as! FullTweetCell)
            tweetVC.tweet = tweets[(index?.row)!]
        } else {
            let postTweetVC = segue.destination as! PostTweetVC
            
            if segue.identifier == "fromReplyBtnOnCelltoPostTweetVC" {
                postTweetVC.retweeting = true
                let index = (sender as! UIButton).tag
                postTweetVC.replyToTweetID = tweets[index].id
                postTweetVC.ownerOfTweet = tweets[index].user.screenName
            } else if segue.identifier == "fromNewBtnOnHomeToPostTweetVC" {
                postTweetVC.retweeting = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FullTweetCell
        performSegue(withIdentifier: "fromCellToTweetVC", sender: cell)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return InfiniteScrollActivityView.defaultHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return loadingMoreView
    }
}

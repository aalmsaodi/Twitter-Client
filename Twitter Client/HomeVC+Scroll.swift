//
//  HomeVC+Scroll.swift
//  Twitter Client
//
//  Created by user on 9/28/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

extension HomeVC: UIScrollViewDelegate {
  
  func pullRefreshControlAction(_ refreshControl: UIRefreshControl) {
    if searchBar.text == "" { //fetching home timeline
      TwitterClient.shared?.getHomeTimeLine(offset: nil) { (tweets, error) in
        if let tweets = tweets {
          self.tweets = tweets
          self.tableView.reloadData()
          self.refreshControl.endRefreshing()
        } else if let error = error {
          print("Error getting home timeline: " + error.localizedDescription)
        }
      }
    } else {                  //search relevent tweets
      TwitterClient.shared?.searchTweets(offset: nil, term: searchBar.text!) { (tweets, error) in
        if let tweets = tweets {
          self.tweets = tweets
          self.tableView.reloadData()
          self.refreshControl.endRefreshing()
        } else if let error = error {
          print("Error getting relevent tweets: " + error.localizedDescription)
        }
      }
    }
  }
  
  fileprivate func getMoreResults() {
    if searchBar.text == "" { //fetching more tweets from home timeline
      TwitterClient.shared?.getHomeTimeLine(offset: tweets.last?.id, completion: { (tweets, error) in
        if let tweets = tweets {
          self.tweets.append(contentsOf: tweets.dropFirst()) //drop first repeated tweet
          self.tableView.reloadData()
          self.loadingMoreView.isHidden = true
          self.isMoreDataLoading = false
        } else if let error = error {
          print("Error getting more home timeline: " + error.localizedDescription)
        }
      })
    } else {                 //fetching more relevent tweets
      TwitterClient.shared?.searchTweets(offset: tweets.last?.id, term: searchBar.text!) { (tweets, error) in
        if let tweets = tweets {
          self.tweets.append(contentsOf: tweets.dropFirst()) //drop first repeated tweet
          self.tableView.reloadData()
          self.loadingMoreView.isHidden = true
          self.isMoreDataLoading = false
        } else if let error = error {
          print("Error getting more relevent tweets: " + error.localizedDescription)
        }
      }
    }
    
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if (!isMoreDataLoading) {
      let scrollViewContentHeight = tableView.contentSize.height
      let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
      
      if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
        isMoreDataLoading = true
        loadingMoreView.startAnimating()
        getMoreResults()
      }
    }
  }
}

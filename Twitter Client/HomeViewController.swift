//
//  HomeViewController.swift
//
//
//  Created by user on 9/27/17.
//
//

import UIKit

class HomeViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var tweets:[Tweet] = []
  var refreshControl:UIRefreshControl!
  var loadingMoreView:InfiniteScrollActivityView!
  var isMoreDataLoading:Bool!
  var searchBar:UISearchBar!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 100
    
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(pullRefreshControlAction(_:)), for: UIControlEvents.valueChanged)
    tableView.insertSubview(refreshControl, at: 0)
    loadingMoreView = InfiniteScrollActivityView()
    loadingMoreView.isHidden = true
    isMoreDataLoading = false
    
    searchBar = UISearchBar()
    searchBar.delegate = self
    searchBar.sizeToFit()
    navigationItem.titleView = searchBar
    
    TwitterClient.shared?.getHomeTimeLine(offset: nil) { (tweets, error) in
      if let tweets = tweets {
        self.tweets = tweets
        self.tableView.reloadData()
      } else if let error = error {
        print("Error getting home timeline: " + error.localizedDescription)
      }
    }
  }
  
  @IBAction func onSignOut(_ sender: Any) {
    TwitterClient.shared?.logout()
    navigationController?.popViewController(animated: true)
  }
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "fromCellToTweetVC" {
      let tweetViewController = segue.destination as! TweetViewController
      let index = tableView.indexPath(for: sender as! FullTweetCell)
      tweetViewController.tweet = tweets[(index?.row)!]
      tweetViewController.returningNewTweet = {[unowned self] tweet in
        if let tweet = tweet {
          self.tweets.insert(tweet, at: 0)
          self.tableView.reloadData()
        }
      }
      tweetViewController.returnCurrentStatesOfRetweetAndFavorBtns = {[unowned self] (retweetBtn, favorBtn) in
        self.tweets[(index?.row)!].isRetweetedBtn = retweetBtn
        self.tweets[(index?.row)!].isRetweetedBtn = retweetBtn
        self.tableView.reloadData()
      }
    } else {
      let postTweetViewController = segue.destination as! PostTweetViewController
      postTweetViewController.returningNewTweet = {[unowned self] tweet in
        if let tweet = tweet {
          self.tweets.insert(tweet, at: 0)
          self.tableView.reloadData()
        }
      }
      if segue.identifier == "fromReplyBtnOnCelltoPostTweetVC" {
        postTweetViewController.retweeting = true
        let index = (sender as! UIButton).tag
        postTweetViewController.tweetReplyingTo = tweets[index]
      } else if segue.identifier == "fromNewBtnOnHomeToPostTweetVC" {
        postTweetViewController.retweeting = false
        postTweetViewController.returningNewTweet = {[unowned self] tweet in
          if let tweet = tweet {
            self.tweets.insert(tweet, at: 0)
            self.tableView.reloadData()
          }
        }
      }
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tweets.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "fullTweetCell") as? FullTweetCell else {return UITableViewCell()}
    cell.tweet = tweets[indexPath.row]
    cell.replyBtn.tag = indexPath.row
    return cell
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

extension HomeViewController: UIScrollViewDelegate {
  
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

extension HomeViewController: UISearchBarDelegate {
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = true
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    TwitterClient.shared?.searchTweets(offset: nil, term: searchBar.text!) { (tweets, error) in
      if let tweets = tweets {
        self.tweets = tweets
        self.tableView.reloadData()
      } else if let error = error {
        print("Error getting relevent tweets: " + error.localizedDescription)
      }
    }
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = false
    searchBar.text = ""
    searchBar.resignFirstResponder()
    TwitterClient.shared?.getHomeTimeLine(offset: nil) { (tweets, error) in
      if let tweets = tweets {
        self.tweets = tweets
        self.tableView.reloadData()
      } else if let error = error {
        print("Error getting home timeline: " + error.localizedDescription)
      }
    }
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
}



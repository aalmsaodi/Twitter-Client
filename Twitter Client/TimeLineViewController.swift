//
//  TimeLineViewController.swift
//
//
//  Created by user on 9/27/17.
//
//

import UIKit

enum TimeLineType : String {
  case homeTimeLine = "homeTimeLineViewController"
  case mentionsTimeLine = "mentionsTimeLineViewController"
}

class TimeLineViewController: UIViewController {
  
  @IBOutlet weak fileprivate var tableView: UITableView!
  @IBOutlet weak private var searchBtnToggle: UIButton!
  @IBOutlet weak private var searchBtnConstraintY: NSLayoutConstraint!
  @IBOutlet weak private var searchBtnConstraintX: NSLayoutConstraint!
  
  private var titleBar:UIView!
  private var originalSearchBtnConstraintY: CGFloat!
  private var originalSearchBtnConstraintX: CGFloat!
  fileprivate var tweets:[Tweet] = []
  fileprivate var refreshControl:UIRefreshControl!
  fileprivate var loadingMoreView:InfiniteScrollActivityView!
  fileprivate var isMoreDataLoading:Bool!
  fileprivate var searchBar:UISearchBar!
  
  public var timeLineType:TimeLineType!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(launchAccountsViewController(_:)))
    self.navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
    
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
    searchBar.isHidden = true
    titleBar = navigationItem.titleView
    
    TwitterClient.shared?.getTimeLine(type: timeLineType, offset: nil) { (tweets, error) in
      if let tweets = tweets {
        self.tweets = tweets
        self.tableView.reloadData()
      } else if let error = error {
        print("Error getting home timeline: " + error.localizedDescription)
      }
    }
  }
  
  @IBAction private func onSearchBtnToggle(_ sender: Any) {
    if searchBar.isHidden {
      navigationItem.titleView = searchBar
      searchBtnToggle.alpha = 0.4
      searchBar.becomeFirstResponder()
      searchBtnConstraintY.constant = view.frame.height/2
    } else {
      searchBtnToggle.alpha = 0.7
      navigationItem.titleView = titleBar
      searchBar.resignFirstResponder()
      searchBar.text = nil
      searchBtnConstraintY.constant = 30
    }
    searchBar.isHidden = !searchBar.isHidden
  }
  
  
  @IBAction private func onSearchBtnPanGesture(_ sender: UIPanGestureRecognizer) {
    let translation = sender.translation(in: view)
    if sender.state == .began {
      originalSearchBtnConstraintY = searchBtnConstraintY.constant
      originalSearchBtnConstraintX = searchBtnConstraintX.constant
    } else if sender.state == UIGestureRecognizerState.changed {
      searchBtnConstraintY.constant = originalSearchBtnConstraintY - translation.y
      searchBtnConstraintX.constant = originalSearchBtnConstraintX - translation.x
    }
  }
  
  @IBAction private func onSignOut(_ sender: Any) {
    TwitterClient.shared?.logout()
    navigationController?.popViewController(animated: true)
  }
  
  @objc private func launchAccountsViewController(_ sth: AnyObject){
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let accountSwitchingViewController = storyboard.instantiateViewController(withIdentifier: "accountSwitchingViewController") as! AccountSwitchingViewController
    appDelegate.window?.rootViewController = accountSwitchingViewController
  }
}

// Mark - Table View Delegates
extension TimeLineViewController: UITableViewDelegate, UITableViewDataSource {
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "fromFullTweetCellToTweetVC" {
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
    } else if segue.identifier == "fromAvatarInCelltoProfileVC"  {
      let profileViewController = segue.destination as! ProfileViewController
      let index = (sender as! UIButton).tag
      profileViewController.user = tweets[index].user
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
    
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "fullTweetCell", for: indexPath) as? FullTweetCell else {return UITableViewCell()}
    cell.tweet = tweets[indexPath.row]
    cell.index = indexPath.row
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath) as! FullTweetCell
    performSegue(withIdentifier: "fromFullTweetCellToTweetVC", sender: cell)
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
    return InfiniteScrollActivityView.defaultHeight
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return loadingMoreView
  }
}

extension TimeLineViewController: UIScrollViewDelegate {
  
  func pullRefreshControlAction(_ refreshControl: UIRefreshControl) {
    if searchBar.text == "" { //fetching home timeline
      TwitterClient.shared?.getTimeLine(type: timeLineType, offset: nil) { (tweets, error) in
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
      TwitterClient.shared?.getTimeLine(type: timeLineType, offset: tweets.last?.id, completion: { (tweets, error) in
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


extension TimeLineViewController: UISearchBarDelegate {
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
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}



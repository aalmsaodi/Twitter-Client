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
    var loadingMoreView:InfiniteScrollActivityView!
    var isMoreDataLoading:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        TwitterClient.shared?.getHomeTimeLine(offset: nil) { (tweets, error) in
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
        
        loadingMoreView = InfiniteScrollActivityView()
        loadingMoreView.isHidden = true
        isMoreDataLoading = false
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        TwitterClient.shared?.logout()
        navigationController?.popViewController(animated: true)
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        TwitterClient.shared?.getHomeTimeLine(offset: nil) { (tweets, error) in
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


//
//  HomeVC+Scroll.swift
//  Twitter Client
//
//  Created by user on 9/28/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

extension HomeVC: UIScrollViewDelegate {
    
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
    
    fileprivate func getMoreResults() {
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
    }
}

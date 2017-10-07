//
//  ProfileViewController.swift
//  Twitter Client
//
//  Created by user on 10/3/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIGestureRecognizerDelegate {
  
  @IBOutlet weak private var tableView: UITableView!
  @IBOutlet weak var profileBannerImage: UIImageView!
  @IBOutlet weak var profileBannerView: UIView!
  @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
  fileprivate var tweets:[Tweet]=[]
  fileprivate var isVerticalPan: Bool!

  fileprivate let profileBannerImageHieght: CGFloat = 150
  fileprivate let maxHeaderHeight: CGFloat = 130
  fileprivate let minHeaderHeight: CGFloat = 40
  fileprivate var previousScrollOffset: CGFloat = 0

  var user: User!
  var passingTranslationValue: ((_ by: CGFloat) -> ())?
  
  let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
  var blurEffectView = UIVisualEffectView()
  
  func somethingWasTapped(_ sth: AnyObject){
    print("Hey there")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = true
    self.navigationController?.view.backgroundColor = .clear
    
    let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(somethingWasTapped(_:)))
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.estimatedRowHeight = 100
    tableView.rowHeight = UITableViewAutomaticDimension
    automaticallyAdjustsScrollViewInsets = true
    
    if let urlString = user.backgroundUrl, let url = URL(string: urlString) {
      profileBannerImage.setImageWith(url)
    } 

    TwitterClient.shared?.getUserTimeLine(screenName: user.screenName, offset: nil) { (tweets, error) in
      if let tweets = tweets {
        self.tweets = tweets
        self.tableView.reloadData()
      } else if let error = error {
        print("Error getting home timeline: " + error.localizedDescription)
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    headerHeightConstraint.constant = maxHeaderHeight
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let topBorder: CGFloat = 0
    let bottomBorder: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
    let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
    let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > topBorder
    let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < bottomBorder
//    let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ProfileInfoCell
//    cell.changingAvatarImageSizeBy = scrollView.contentOffset.y
    
    if canAnimateHeader(scrollView) {
      var newHeight = headerHeightConstraint.constant
      if isScrollingDown {
        newHeight = max(minHeaderHeight, headerHeightConstraint.constant - abs(scrollDiff))
      } else if isScrollingUp {
        newHeight = min(maxHeaderHeight, headerHeightConstraint.constant + abs(scrollDiff))
      }
    if newHeight != self.headerHeightConstraint.constant {
      self.headerHeightConstraint.constant = newHeight
      self.setScrollPosition(position: self.previousScrollOffset)
    }
      previousScrollOffset = scrollView.contentOffset.y
    }
    
//    self.view.bringSubview(toFront: profileBannerView)
  }
  
  func setScrollPosition(position: CGFloat) {
    self.tableView.contentOffset = CGPoint(x: tableView.contentOffset.x, y: position)
  }
  
  func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
    let scrollViewMaxHeight = scrollView.frame.height + self.headerHeightConstraint.constant - minHeaderHeight
    return scrollView.contentSize.height > scrollViewMaxHeight
  }
  
//  func setupBlur() {
//    UIView.animate(withDuration: 1.0) {
//      self.blurEffectView = UIVisualEffectView(effect: self.blurEffect)
//      self.blurEffectView.frame = self.backgroundImage.frame
//      self.backgroundImage.addSubview(self.blurEffectView)
//      self.blurEffectView = self.backgroundImage.subviews[0] as! UIVisualEffectView
//      self.blurEffectView.layer.speed = 0
//    }
//  }
//  
//  func addjustBlur(blurIntensity: CGFloat) {
//    self.blurEffectView.layer.timeOffset = CFTimeInterval(blurIntensity)
//  }
  
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let panRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {return false}
    
    let velocity = panRecognizer.velocity(in: self.view)
    isVerticalPan = abs(velocity.x) < abs(velocity.y)
    
    return true
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}


extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tweets.count + 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.row {
    case 0:
      let cell = tableView.dequeueReusableCell(withIdentifier: "profileInfoCell", for: indexPath) as! ProfileInfoCell
      cell.user = user
      cell.superview?.bringSubview(toFront: cell.avatarImage)
      cell.contentView.superview?.clipsToBounds = false
      return cell
    default:
      let cell = tableView.dequeueReusableCell(withIdentifier: "fullTweetCell", for: indexPath) as! FullTweetCell
      cell.tweet = tweets[indexPath.row-1]
      cell.index = indexPath.row
      return cell
    }
  }

}

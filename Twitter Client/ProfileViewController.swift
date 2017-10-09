//
//  ProfileViewController.swift
//  Twitter Client
//
//  Created by user on 10/3/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIGestureRecognizerDelegate {
  
  @IBOutlet weak fileprivate var tableView: UITableView!
  @IBOutlet weak fileprivate var profileBannerImage: UIImageView!
  @IBOutlet weak private var headerHeightConstraint: NSLayoutConstraint!
  
  private var isVerticalPan: Bool!
  private let navigationBarAppearanceTrigger: CGFloat = 120
  private let minHeaderHeight: CGFloat = 28
  fileprivate var refreshControl:UIRefreshControl!
  fileprivate var loadingMoreView:InfiniteScrollActivityView!
  fileprivate var isMoreDataLoading:Bool!
  fileprivate var avatarImage = UIImageView()
  fileprivate var blurProfileBannerImage = UIImageView()
  fileprivate var tweets:[Tweet]=[]
  
  var user: User!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(launchAccountsViewController(_:)))
    self.navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.estimatedRowHeight = 100
    tableView.rowHeight = UITableViewAutomaticDimension
    automaticallyAdjustsScrollViewInsets = true
    
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(pullRefreshControlAction(_:)), for: UIControlEvents.valueChanged)
    tableView.insertSubview(refreshControl, at: 0)
    loadingMoreView = InfiniteScrollActivityView()
    loadingMoreView.isHidden = true
    isMoreDataLoading = false
    
    if let urlString = user.backgroundUrl {
      imageFromURL(urlString: urlString, completion: {image in
        self.profileBannerImage.image = image
        self.blurProfileBannerImage.frame = self.profileBannerImage.frame
        self.blurProfileBannerImage.image = self.blurImage(image: image)
      })
    }
    
    if let url = URL(string: user.avatarImageUrl) {
      avatarImage.setImageWith(url)
      avatarImage.layer.cornerRadius = 5
      avatarImage.layer.masksToBounds = true
      avatarImage.frame.size = CGSize(width: 40, height: 40)
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
    self.navigationController?.navigationBar.isTranslucent = true
    self.navigationController?.view.backgroundColor = .clear
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.navigationBar.isTranslucent = false
    self.navigationController?.view.backgroundColor = UIColor(displayP3Red: 0x66/0xFF, green: 0x76/0xFF, blue: 0x7F/0xFF, alpha: 1)
  }
  
  // MARK: - Annimation and gesture Logic
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileInfoCell {
      cell.changingAvatarImageSizeBy = headerHeightConstraint.constant
    }
    
    if scrollView.contentOffset.y > minHeaderHeight {
      self.headerHeightConstraint.constant = 0
      UIView.animate(withDuration: 0.3, animations: {
        self.navigationController?.navigationBar.setBackgroundImage(self.blurProfileBannerImage.image, for: .default)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = self.user.name
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.avatarImage)
      })
    } else {
      headerHeightConstraint.constant = navigationBarAppearanceTrigger - scrollView.contentOffset.y
      self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
      self.navigationController?.navigationBar.isTranslucent = true
      navigationItem.leftBarButtonItem = nil
      self.navigationItem.title = ""
    }
    
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
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let panRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {return false}
    let velocity = panRecognizer.velocity(in: self.view)
    isVerticalPan = abs(velocity.x) < abs(velocity.y)
    return true
  }
  
  @objc private func launchAccountsViewController(_ sth: AnyObject){
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let accountSwitchingViewController = storyboard.instantiateViewController(withIdentifier: "accountSwitchingViewController") as! AccountSwitchingViewController
    appDelegate.window?.rootViewController = accountSwitchingViewController
  }
}

// MARK: - TableView delegates
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tweets.count + 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.row {
    case 0:
      let cell = tableView.dequeueReusableCell(withIdentifier: "profileInfoCell", for: indexPath) as! ProfileInfoCell
      cell.user = user
      cell.isDescriptionCurrentPage = {[unowned self] isDescriptionPage in
        if isDescriptionPage {
          self.profileBannerImage.alpha = 0.5
        } else {
          self.profileBannerImage.alpha = 1
        }
      }
      cell.takePicForProfileAvatar = {
        self.performSegue(withIdentifier: "fromProfileViewControllerToTakingNewPic", sender: self)
      }
      return cell
    default:
      let cell = tableView.dequeueReusableCell(withIdentifier: "fullTweetCell", for: indexPath) as! FullTweetCell
      cell.tweet = tweets[indexPath.row-1]
      cell.index = indexPath.row
      return cell
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "fromProfileViewControllerToTakingNewPic" {
      let takingNewPhotoViewController = segue.destination as! TakingNewPhotoViewController
      takingNewPhotoViewController.avatarUrl = user.avatarImageUrl
    }
  }
}

// MARK: - Refresh and Loadmore scrolling
extension ProfileViewController: UIScrollViewDelegate {
  func pullRefreshControlAction(_ refreshControl: UIRefreshControl) {
    TwitterClient.shared?.getUserTimeLine(screenName: user.screenName, offset: nil) { (tweets, error) in
      if let tweets = tweets {
        self.tweets = tweets
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
      } else if let error = error {
        print("Error getting home timeline: " + error.localizedDescription)
      }
    }
  }
  
  fileprivate func getMoreResults() {
    TwitterClient.shared?.getUserTimeLine(screenName: user.screenName, offset: tweets.last?.id) { (tweets, error) in
      if let tweets = tweets {
        self.tweets.append(contentsOf: tweets.dropFirst()) //drop first repeated tweet
        self.tableView.reloadData()
        self.loadingMoreView.isHidden = true
        self.isMoreDataLoading = false
      } else if let error = error {
        print("Error getting home timeline: " + error.localizedDescription)
      }
    }
  }
}

// MARK: - Helper functions
extension ProfileViewController {
  func blurImage(image:UIImage) -> UIImage? {
    let context = CIContext(options: nil)
    let inputImage = CIImage(image: image)
    let originalOrientation = image.imageOrientation
    let originalScale = image.scale
    let filter = CIFilter(name: "CIGaussianBlur")
    filter?.setValue(inputImage, forKey: kCIInputImageKey)
    filter?.setValue(10.0, forKey: kCIInputRadiusKey)
    let outputImage = filter?.outputImage
    var cgImage:CGImage?
    if let asd = outputImage {
      cgImage = context.createCGImage(asd, from: (inputImage?.extent)!)
    }
    if let cgImageA = cgImage {
      return UIImage(cgImage: cgImageA, scale: originalScale, orientation: originalOrientation)
    }
    
    return nil
  }
  
  public func imageFromURL(urlString: String, completion: @escaping (UIImage)->()) {
    URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
      DispatchQueue.main.async(execute: { () -> Void in
        if let image = UIImage(data: data!) {
          completion(image)
        }
      })
      
    }).resume()
  }
}

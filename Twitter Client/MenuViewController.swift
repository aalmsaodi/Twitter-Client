//
//  MenuViewController.swift
//  Twitter Client
//
//  Created by user on 10/3/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

enum IndexVC: Int {
  case profileVC = 0
  case homeLineVC = 1
  case mentionsLineVC = 2
}

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var tableView: UITableView!
  
  private var profileNavigationController: UIViewController!
  private var homeNavigationController: UIViewController!
  private var mentionsNavigationController: UIViewController!
  private var accountSwitchingViewController: UIViewController!
  
  var viewControllers: [UIViewController] = []
  let menuTitles = ["Profile", "Home Timeline", "Mentions Timeline", "Accounts"]

  var burgerViewController: BurgerViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    profileNavigationController = storyboard.instantiateViewController(withIdentifier: "profileNavigationController") as! UINavigationController
    homeNavigationController = storyboard.instantiateViewController(withIdentifier: "homeNavigationController") as! UINavigationController
    mentionsNavigationController = storyboard.instantiateViewController(withIdentifier: "mentionsNavigationController") as! UINavigationController
    accountSwitchingViewController = storyboard.instantiateViewController(withIdentifier: "accountSwitchingViewController") as! AccountSwitchingViewController
    
    viewControllers.append(profileNavigationController)
    viewControllers.append(homeNavigationController)
    viewControllers.append(mentionsNavigationController)
    viewControllers.append(accountSwitchingViewController)
    
    let profileViewController = profileNavigationController.childViewControllers[0] as! ProfileViewController
    profileViewController.user = TwitterClient.currentAccount.user
    burgerViewController.contentViewController = profileNavigationController
    
    tableView.rowHeight = view.frame.height/CGFloat(menuTitles.count)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "menuButtonCell", for: indexPath) as? MenueButtonCell else {return UITableViewCell()}
    
    cell.menuTabLabel.text = menuTitles[indexPath.row]
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    switch indexPath.row {
    case Int(viewControllers.index(of: profileNavigationController)!):
      let profileViewController = profileNavigationController.childViewControllers[0] as! ProfileViewController
      profileViewController.user = TwitterClient.currentAccount.user
      
    case Int(viewControllers.index(of: homeNavigationController)!):
      let homeTimeLineViewController = homeNavigationController.childViewControllers[0] as! TimeLineViewController
      homeTimeLineViewController.timeLineType = TimeLineType.homeTimeLine
      
    case Int(viewControllers.index(of: mentionsNavigationController)!):
      let mentionsTimeLineViewController = mentionsNavigationController.childViewControllers[0] as! TimeLineViewController
      mentionsTimeLineViewController.timeLineType = TimeLineType.mentionsTimeLine
      
    case Int(viewControllers.index(of: accountSwitchingViewController)!):
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      appDelegate.window?.rootViewController = accountSwitchingViewController
      return
      
    default:
      break
    }
    burgerViewController.contentViewController = viewControllers[indexPath.row]
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return menuTitles.count
  }
}

//
//  MenuViewController.swift
//  Twitter Client
//
//  Created by user on 10/3/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var tableView: UITableView!
  
  private var profileNavigationController: UIViewController!
  private var homeNavigationController: UIViewController!
  private var mentionsNavigationController: UIViewController!
  
  var viewControllers: [UIViewController] = []
  let menuTitles = ["Profile", "Home Timeline", "Mentions Timeline"]

  var burgerViewController: BurgerViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    profileNavigationController = storyboard.instantiateViewController(withIdentifier: "profileNavigationController")
    homeNavigationController = storyboard.instantiateViewController(withIdentifier: "homeNavigationController")
    mentionsNavigationController = storyboard.instantiateViewController(withIdentifier: "mentionsNavigationController")
    
    viewControllers.append(profileNavigationController)
    viewControllers.append(homeNavigationController)
    viewControllers.append(mentionsNavigationController)
    
    burgerViewController.contentViewController = homeNavigationController
    
    tableView.rowHeight = view.frame.height/CGFloat(menuTitles.count)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "menuButtonCell", for: indexPath) as? MenueButtonCell else {return UITableViewCell()}
    
    cell.menuTabLabel.text = menuTitles[indexPath.row]
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    burgerViewController.contentViewController = viewControllers[indexPath.row]
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return menuTitles.count
  }
}

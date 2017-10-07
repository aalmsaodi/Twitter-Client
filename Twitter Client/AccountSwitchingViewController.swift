//
//  AccountSwitchingViewController.swift
//  Twitter Client
//
//  Created by user on 10/6/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class AccountSwitchingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
  
  @IBOutlet weak private var tableView: UITableView!
  private var isHorizentalPan: Bool!
  private var indexPath: IndexPath!
  
  var storybrd: UIStoryboard!
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 100
    
    storybrd = UIStoryboard(name: "Main", bundle: nil)
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let viewAddBtn = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
    viewAddBtn.backgroundColor = UIColor.gray
    viewAddBtn.addTarget(self, action: #selector(addNewAccount), for: .touchUpInside)
    return viewAddBtn
  }
  
  func addNewAccount() {
    TwitterClient.shared?.login()
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 100
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return TwitterClient.accounts.count
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedAcount = TwitterClient.accounts[indexPath.row]
    TwitterClient.shared?.requestSerializer.removeAccessToken()
    TwitterClient.shared?.requestSerializer.saveAccessToken(selectedAcount.accessToken)
    TwitterClient.currentAccount = selectedAcount
    
    let burgerViewController = storybrd.instantiateViewController(withIdentifier: "burgerViewController") as! BurgerViewController
    appDelegate.window?.rootViewController = burgerViewController
    
    let menuViewController = storybrd.instantiateViewController(withIdentifier: "menuViewController") as! MenuViewController
    
    menuViewController.burgerViewController = burgerViewController
    burgerViewController.menuViewController = menuViewController
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath)  as? AccountCell else { return UITableViewCell()}
    cell.user = TwitterClient.accounts[indexPath.row].user
    let cellPanGesture = UIPanGestureRecognizer(target: self, action: #selector(onCellPanGesture(_:)))
    cellPanGesture.delegate = self
    cell.addGestureRecognizer(cellPanGesture)
    return cell
  }
  
  func onCellPanGesture(_ sender: UIPanGestureRecognizer) {
    if isHorizentalPan {
      let cell = sender.view as! AccountCell
      cell.animateAccountView(sender, removeCell: {
        if let indexPath = self.tableView.indexPath(for: cell) {
          self.tableView.beginUpdates()
          TwitterClient.accounts.remove(at: indexPath.row)
          TwitterClient.shared?.saveAccounts()
          self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.right)
          self.tableView.endUpdates()
        }
      })
    }
  }
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let panRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {return false}
    let velocity = panRecognizer.velocity(in: self.view)
    isHorizentalPan = abs(velocity.x) > abs(velocity.y)
    return true
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
}

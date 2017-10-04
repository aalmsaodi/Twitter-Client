//
//  BurgerViewController.swift
//  Twitter Client
//
//  Created by user on 10/3/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class BurgerViewController: UIViewController {
  
  @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
  @IBOutlet weak var menuView: UIView!
  @IBOutlet weak var contentView: UIView!
  
  var originalLeftMargin: CGFloat!
  
  var menuViewController: UIViewController! {
    didSet {
      view.layoutIfNeeded()
      menuView.addSubview(menuViewController.view)
    }
  }
  var contentViewController: UIViewController! {
    didSet (oldContentViewController) {
      view.layoutIfNeeded()

      if oldContentViewController != nil {
        oldContentViewController.willMove(toParentViewController: nil)
        oldContentViewController.removeFromParentViewController()
        oldContentViewController.didMove(toParentViewController: nil)
      }
      
      contentViewController.willMove(toParentViewController: self)
      contentView.addSubview(contentViewController.view)
      contentViewController.didMove(toParentViewController: self)
      
      UIView.animate(withDuration: 0.3) { 
        self.leftMarginConstraint.constant = 0
        self.view.layoutIfNeeded()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
    let translation = sender.translation(in: view)
    let velocity = sender.velocity(in: view)
    
    if sender.state == UIGestureRecognizerState.began {
      originalLeftMargin = leftMarginConstraint.constant
    } else if sender.state == UIGestureRecognizerState.changed {
      if originalLeftMargin + translation.x > 0 {
        leftMarginConstraint.constant = originalLeftMargin + translation.x
      }
    } else if sender.state == UIGestureRecognizerState.ended {
      UIView.animate(withDuration: 0.3, animations: {
        if velocity.x > 0 { //openning the menu
          self.leftMarginConstraint.constant = self.view.frame.size.width/2
        } else {            //closing the menu
          self.leftMarginConstraint.constant = 0
        }
        self.view.layoutIfNeeded()
      })
    }
  }
  
}

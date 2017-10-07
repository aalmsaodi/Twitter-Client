//
//  BurgerViewController.swift
//  Twitter Client
//
//  Created by user on 10/3/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class BurgerViewController: UIViewController, UIGestureRecognizerDelegate {
  
  @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
  @IBOutlet weak var menuView: UIView!
  @IBOutlet weak var contentView: UIView!
  
  fileprivate var originalLeftMargin: CGFloat!
  fileprivate var isHorizentalPan: Bool!
  
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
    let translation = sender.translation(in: view).x
    let velocity = sender.velocity(in: view).x
//    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
//    let blurEffectView = UIVisualEffectView(effect: blurEffect)
//    blurEffectView.frame = contentView.bounds
//    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    if isHorizentalPan {
      if sender.state == UIGestureRecognizerState.began {
        originalLeftMargin = leftMarginConstraint.constant
      } else if sender.state == UIGestureRecognizerState.changed {
        if originalLeftMargin + translation > 0 {
          leftMarginConstraint.constant = originalLeftMargin + translation
        }
      } else if sender.state == UIGestureRecognizerState.ended {
        UIView.animate(withDuration: 0.3, animations: {
          if abs(self.leftMarginConstraint.constant - self.originalLeftMargin) > 50 {
            if velocity > 0 { //finish Auto-openning the menu
              self.leftMarginConstraint.constant = self.view.frame.size.width/2
//              self.contentView.addSubview(blurEffectView)
            } else {            //finish Auto-closing the menu
              self.leftMarginConstraint.constant = 0
              for subview in self.contentView.subviews {
                if subview is UIVisualEffectView {
                  subview.removeFromSuperview()
                }
              }
            }
            self.view.layoutIfNeeded()
          }
          else if velocity > 0  { //failed to open menue
            self.leftMarginConstraint.constant = 0
          } else if velocity < 0 { //faild to close the menu
            self.leftMarginConstraint.constant = self.view.frame.size.width/2
          }
        })
      }
    }
  }
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let panRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {return false}
    let velocity = panRecognizer.velocity(in: self.view)
    isHorizentalPan = abs(velocity.x) > abs(velocity.y)
    return true
  }
  
}

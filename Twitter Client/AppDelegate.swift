//
//  AppDelegate.swift
//  Twitter Client
//
//  Created by user on 9/26/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import AFNetworking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    if (TwitterClient.shared?.loadAccounts())! {
      print("welecome \(TwitterClient.currentAccount.user.name)")

      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      
      let burgerViewController = storyboard.instantiateViewController(withIdentifier: "burgerViewController") as! BurgerViewController
      window?.rootViewController = burgerViewController
      
      let menuViewController = storyboard.instantiateViewController(withIdentifier: "menuViewController") as! MenuViewController
      
      menuViewController.burgerViewController = burgerViewController
      burgerViewController.menuViewController = menuViewController
    }
    
    return true
  }
  
  // OAuth step 2
  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    
    let requestToken = BDBOAuth1Credential(queryString: url.query)
    TwitterClient.shared?.fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) in
      print("got access token")
      TwitterClient.shared?.requestSerializer.saveAccessToken(accessToken)
      
      TwitterClient.shared?.getCurrentAccount(completion: { (user: User?, error: Error?) in
        if let user = user {
          TwitterClient.accounts.append(Account(user: user, accessToken: accessToken))
          TwitterClient.shared?.saveAccounts()
          TwitterClient.currentAccount = (Account(user: user, accessToken: accessToken))
          
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let burgerViewController = storyboard.instantiateViewController(withIdentifier: "burgerViewController")as! BurgerViewController
          self.window?.rootViewController = burgerViewController
          
          let menuViewController = storyboard.instantiateViewController(withIdentifier: "menuViewController") as! MenuViewController
          
          menuViewController.burgerViewController = burgerViewController
          burgerViewController.menuViewController = menuViewController
        } else {
          print(error ?? "No user got logged in")
        }
      })
      
    }, failure: { (error: Error?) in
      print ("fail to recieve access token")
    })
    
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
}


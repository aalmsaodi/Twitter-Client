//
//  TwitterClient.swift
//  Twitter Client
//
//  Created by user on 9/26/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit
import AFNetworking
import BDBOAuth1Manager
import SwiftyJSON

 let consumerKey = "3x5uWdsAUIVb7IvLTiiRl4mrY"
 let consumerSecret = "Fgu2D5y1Cq3moOSMx1nbJW2SzCDSvINoCoGU38SjwJtn5bXNYt"

 let requestTokenURL = "https://api.twitter.com/oauth/request_token"
 let authorizeURL = "https://api.twitter.com/oauth/authorize"
 let accessTokenURL = "https://api.twitter.com/oauth/access_token"
let twitterBaseURL = URL(string:"https://api.twitter.com")
 let callbackURLString = "TwitterClient://"

class TwitterClient: BDBOAuth1RequestOperationManager {
    
    static let shared = TwitterClient(baseURL: twitterBaseURL, consumerKey: consumerKey, consumerSecret: consumerSecret)
   
    static var loggedInUser:User!
    
    func createFavorite(id:String, completion: @escaping (Error?)->() ) {
        let params = ["id": id]
        
        post("1.1/favorites/create.json", parameters: params, success: { (operation:AFHTTPRequestOperation, response: Any) in
            print("Favorite tweet, succes!")
            completion(nil)
        }) { (operation: AFHTTPRequestOperation?, error:Error) in
            completion(error)
        }
    }
    
    func destroyFavorite(id:String, completion: @escaping (Error?)->() ) {
        let params = ["id": id]
        
        post("1.1/favorites/destroy.json", parameters: params, success: { (operation:AFHTTPRequestOperation, response: Any) in
            print("Destroy tweet, succes!")
            completion(nil)
        }) { (operation: AFHTTPRequestOperation?, error:Error) in
            completion(error)
        }
    }
    
    func postTweet(tweet:String, replyToTweetID:String?, ownerOfTweet:String?, completion: @escaping (Error?)->() ) {
        var params:[String:Any]!
        
        if let replyingTo = replyToTweetID, let ownerOfTweet = ownerOfTweet { //Reply to a Tweet
           params = ["status": "\(ownerOfTweet) \(tweet)", "in_reply_to_status_id":replyingTo]
        } else { //Post a new Tweet
           params = ["status": tweet]
        }
        
        post("1.1/statuses/update.json", parameters: params, success: { (operation:AFHTTPRequestOperation, response: Any) in
            print("Post new tweet, succes!")
            completion(nil)
        }) { (operation: AFHTTPRequestOperation?, error:Error) in
            completion(error)
        }
    }
    
    func retweetIt(id:String, completion: @escaping (Error?)->() ) {
        let params: [String:Any] = ["id": id]
        post("1.1/statuses/retweet.json", parameters: params, success: { (operation:AFHTTPRequestOperation, response: Any) in
            print("Retweet, succes!")
            completion(nil)
        }) { (operation: AFHTTPRequestOperation?, error:Error) in
            completion(error)
        }
    }
    
    func getHomeTimeLine(offset:String?, completion: @escaping ([Tweet]?, Error?) -> ()) {
        var params:[String:Any]!
        
        if let offset_id = offset {
            params = ["max_id": offset_id]
        }
        get("1.1/statuses/home_timeline.json", parameters: params, success: { (operation:AFHTTPRequestOperation, response: Any) in
            guard let tweetDictionaries = response as? [[String: Any]] else {
                let error = "Failed to parse tweets" as! Error
                completion(nil, error)
                return
            }
            
            let tweets = tweetDictionaries.flatMap({ (dictionary) -> Tweet in
                Tweet(timeLine: JSON(dictionary))
            })

            completion(tweets, nil)
            
        }) { (operation: AFHTTPRequestOperation?, error: Error) in
            completion(nil, error)
        }
    }

    
    func getCurrentAccount(completion: @escaping (User?, Error?) -> ()) {
        get("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: AFHTTPRequestOperation, response: Any) in
            guard let userDictionary = response as? [String:Any] else {
                completion(nil, "Unable to create user dictionary" as? Error)
                return
            }
            completion(User(user: JSON(userDictionary)), nil)
            
        }) { (operation: AFHTTPRequestOperation?, error: Error) in
            completion(nil, error)
        }
    }
    
    func login() {
        requestSerializer.removeAccessToken()
        
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string:"TwitterClient://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) in
            
            if let authURL = URL(string:"https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token as String)") {
                
                print ("Got request token")
                UIApplication.shared.open(authURL, options: [:], completionHandler: nil)
            }
        }) { (error: Error?) in
            print(error ?? "Failed to log in")
        }
    }
    
    func logout() {
        requestSerializer.removeAccessToken()
        UserDefaults.standard.removeObject(forKey: "loggedUser")
        print("Have a good day \(TwitterClient.loggedInUser.name)")
        TwitterClient.loggedInUser = nil
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginVC
    }
    
}

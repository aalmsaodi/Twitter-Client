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

class TwitterClient: BDBOAuth1RequestOperationManager {
    
    static var loggedInUser:User!
    static let path = Bundle.main.path(forResource: "TwitterConstants", ofType: "plist")!
    static let twitterConstants = NSDictionary(contentsOfFile: path) as! [String: String]
    static let shared = TwitterClient(baseURL: URL(string:twitterConstants["twitterBaseURL"]!), consumerKey: twitterConstants["consumerKey"], consumerSecret: twitterConstants["consumerSecret"])
    
    func searchTweets(offset:String?, term:String, completion: @escaping ([Tweet]?, Error?) -> ()) {
        var params: [String:Any] = ["q": term]
        if let offset_id = offset {
            params["max_id"] = offset_id
        }
        get("1.1/search/tweets.json", parameters: params, success: { (operation: AFHTTPRequestOperation, response: Any) in
            guard let responseDictionary = response as? [String:Any], let tweetsNSArray = responseDictionary["statuses"] as? NSArray else {
                completion(nil, "No search results was able to fetch" as? Error)
                return
            }
            let tweets = tweetsNSArray.flatMap({ (dictionary) -> Tweet in
                Tweet(dictTweet: JSON(dictionary))
            })
            completion(tweets, nil)
        }) { (operation: AFHTTPRequestOperation?, error: Error) in
            completion(nil, error)
        }
    }
    
    func unretweetIt(tweet:Tweet, completion: @escaping (Error?)->()) {
        var original_tweet_id:String!
        // step 1: Determine the id of the original tweet.
        if !tweet.retweetedBtn {
            completion("you cannot unretweet a tweet that has not retweeted" as? Error)
        } else if tweet.retweetedBy?["name"] == nil {
            original_tweet_id = tweet.id
        } else {
            original_tweet_id = tweet.retweetedBy?["id"]
        }
        
        // step 2: Get id of the logged-in user's retweet.
        TwitterClient.shared?.getFullTweet(id: original_tweet_id, includeMyRetweet: "t") { (tweet, error) in
            if let fetchedTweet = tweet {
        // step 3: Step 3: Delete the retweet
                if let retweet_id = fetchedTweet.currentUserID {
                    TwitterClient.shared?.destroyTweet(id: retweet_id) { error in
                        completion(error)
                    }
                }
            } else {
                completion("untweeting failed!! it was unable to fetch the original tweet" as? Error)
            }
        }
    }
    
    func retweetIt(id:String, completion: @escaping (Error?)->() ) {
        let params: [String:Any] = ["id": id]
        post("1.1/statuses/retweet.json", parameters: params, success: { (operation:AFHTTPRequestOperation, response: Any) in
            completion(nil)
        }) { (operation: AFHTTPRequestOperation?, error:Error) in
            completion(error)
        }
    }
    
    func destroyTweet(id:String, completion: @escaping (Error?) -> ()) {
        let params = ["id": id]
        post("1.1/statuses/destroy.json", parameters: params, success: { (operation:AFHTTPRequestOperation, response: Any) in
            print("Tweet was destroyed, succes!")
            completion(nil)
        }) { (operation: AFHTTPRequestOperation?, error:Error) in
            completion("No tweet was destroyed, fail!" as? Error)
        }
    }
    
    func getFullTweet(id:String, includeMyRetweet:String, completion: @escaping (Tweet?, Error?) -> ()) {
        let params = ["id": id, "include_my_retweet": includeMyRetweet]
        get("1.1/statuses/show.json", parameters: params, success: { (operation: AFHTTPRequestOperation, response: Any) in
            guard let tweetDict = response as? [String:Any] else {
                completion(nil, "Unable to fetch tweet with id \(id)" as? Error)
                return
            }
            completion(Tweet(dictTweet: JSON(tweetDict)), nil)
        }) { (operation: AFHTTPRequestOperation?, error: Error) in
            completion(nil, error)
        }
    }
    
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
    
    func postTweet(tweet:String, replyToTweetID:String?, ownerOfTweet:String?, completion: @escaping (Error?, _ newTweetID:String?)->() ) {
        var params:[String:Any]!
        if let replyingTo = replyToTweetID, let ownerOfTweet = ownerOfTweet { //Reply to a Tweet
           params = ["status": "\(ownerOfTweet) \(tweet)", "in_reply_to_status_id":replyingTo]
        } else { //Post a new Tweet
           params = ["status": tweet]
        }
        post("1.1/statuses/update.json", parameters: params, success: { (operation:AFHTTPRequestOperation, response: Any) in
            print("Post new tweet, succes!")
            let retweetedID = JSON(response)["id_str"].string
            completion(nil, retweetedID)
        }) { (operation: AFHTTPRequestOperation?, error:Error) in
            completion(error, nil)
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
                Tweet(dictTweet: JSON(dictionary))
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

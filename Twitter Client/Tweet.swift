//
//  Tweet.swift
//  Twitter Client
//
//  Created by user on 9/27/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import Foundation
import SwiftyJSON

class Tweet {
  
  var id:String
  var user:User
  var tweetText:String
  var creationDate:String
  var tweetAge:String
  var retweetedBy:[String:String]?
  var currentUserID:String?
  var favoriteCount:Int
  var isFavoritedBtn = false
  var retweetCount:Int
  var isRetweetedBtn = false
  
  init(id:String , user:User, tweetText:String, creationDate:String, tweetAge:String, retweetedBy: String?) {
    self.id = id
    self.user = user
    self.tweetText = tweetText
    self.creationDate = creationDate
    self.tweetAge = tweetAge
    if let retweetedBy = retweetedBy {
      self.retweetedBy = ["name": retweetedBy]
    }
    self.favoriteCount = 0
    self.isFavoritedBtn = false
    self.retweetCount = 0
    self.isRetweetedBtn = false
  }
  
  init(dictTweet: JSON) {
    id = dictTweet["id_str"].string!
    user = User(user: dictTweet["user"])
    tweetText = dictTweet["text"].string!
    
    if let currentUserRetweet = dictTweet["current_user_retweet"].dictionaryObject {
      currentUserID = currentUserRetweet["id_str"] as? String
    }
    
    favoriteCount = dictTweet["favorite_count"].int!
    isFavoritedBtn = dictTweet["favorited"].bool!
    retweetCount = dictTweet["retweet_count"].int!
    isRetweetedBtn = dictTweet["retweeted"].bool!
    
    if let retweetedByUserName = dictTweet["retweeted_status"]["user"]["name"].string, let retweetedByUserID = dictTweet["retweeted_status"]["user"]["id_str"].string {
      retweetedBy = ["name": retweetedByUserName, "id": retweetedByUserID]
      
      if let endOfRT = tweetText.range(of: ": ") {
        tweetText = tweetText.substring(from: endOfRT.upperBound)
      }
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "E M d HH:mm:ss Z y"
    let createdAtString = dictTweet["created_at"].string!
    let currentTime = Date()
    let createdAt = formatter.date(from: createdAtString)
    let requestedComponent:Set<Calendar.Component> = [.year,.month,.day,.hour,.minute,.second]
    let userCalendar = Calendar.current
    let timeDifference = userCalendar.dateComponents(requestedComponent, from: createdAt!, to: currentTime)
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    creationDate = formatter.string(from: createdAt!)
    if timeDifference.day! > 0 || timeDifference.month! > 0 || timeDifference.year! > 0 {
      formatter.timeStyle = .none
      tweetAge = formatter.string(from: createdAt!)
    } else if timeDifference.hour! > 0 {
      tweetAge = "\(timeDifference.hour!)h"
    } else if timeDifference.minute! > 0 {
      tweetAge = "\(timeDifference.minute!)m"
    } else {
      tweetAge = "\(timeDifference.second!)s"
    }
  }
  
  func retweet(completion: @escaping (Error?)->()) {
    TwitterClient.shared?.retweetIt(id: self.id, completion: { (error) in
      if error == nil {
        self.isRetweetedBtn = true
        self.retweetCount += 1
        completion(nil)
      } else {
        self.isRetweetedBtn = false
        completion(error)
      }
    })
  }
  
  func unretweet(completion: @escaping (Error?)->()) {
    TwitterClient.shared?.unretweetIt(tweet: self, completion: { (error) in
      if error == nil {
        self.isRetweetedBtn = false
        self.retweetCount -= 1
        completion(nil)
      } else {
        self.isRetweetedBtn = true
        completion(error)
      }
    })
  }
  
  func favorite(completion: @escaping (Error?)->()) {
    TwitterClient.shared?.createFavorite(id: self.id, completion: { error in
      if error == nil {
        self.isFavoritedBtn = true
        self.favoriteCount += 1
        completion(nil)
      } else {
        completion(error)
      }
    })
  }
  
  func unfavorite(completion: @escaping (Error?)->()) {
    TwitterClient.shared?.destroyFavorite(id: self.id, completion: { error in
      if error == nil {
        self.isFavoritedBtn = false
        self.favoriteCount -= 1
        completion(nil)
      } else {
        completion(error)
      }
    })
  }
}

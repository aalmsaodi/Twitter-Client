//
//  User.swift
//  Twitter Client
//
//  Created by user on 9/26/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import Foundation
import SwiftyJSON

class User: NSObject, NSCoding {
  
  var name:String
  var screenName:String
  var avatarImageUrl:String
  var backgroundUrl:String?
  var followingsCount:Int?
  var followersCount:Int?
  var tweetsCount:Int?
  
  init(user: JSON) {
    name = user["name"].string!
    screenName = "@\(user["screen_name"].string!)"
    avatarImageUrl = user["profile_image_url_https"].string!
    backgroundUrl = user["profile_background_image_url_https"].string
    followingsCount = user["friends_count"].int!
    followersCount = user["followers_count"].int!
    tweetsCount = user["statuses_count"].int!
  }
  
  private init(name:String, screen:String, avatarUrl:String, backgroundUrl:String, followingsCount:Int, followersCount:Int, tweetsCount:Int){
    self.name = name
    self.screenName = screen
    self.avatarImageUrl = avatarUrl
    self.backgroundUrl = backgroundUrl
    self.followingsCount = followingsCount
    self.followersCount = followersCount
    self.tweetsCount = tweetsCount
  }
  
  // MARK: NSCoding
  func encode(with aCoder: NSCoder) {
    aCoder.encode(self.name, forKey: "name")
    aCoder.encode(self.screenName, forKey: "screen")
    aCoder.encode(self.avatarImageUrl, forKey: "avatarUrl")
    aCoder.encode(self.backgroundUrl, forKey: "backgroundUrl")
    aCoder.encode(self.followingsCount, forKey: "followingsCount")
    aCoder.encode(self.followersCount, forKey: "followersCount")
    aCoder.encode(self.tweetsCount, forKey: "tweetsCount")
  }
  
  required convenience init?(coder decoder: NSCoder) {
    guard let name = decoder.decodeObject(forKey: "name") as? String,
      let screen = decoder.decodeObject(forKey: "screen") as? String,
      let avatarUrl = decoder.decodeObject(forKey: "avatarUrl") as? String,
      let backgroundUrl = decoder.decodeObject(forKey: "backgroundUrl") as? String,
      let followingsCount = decoder.decodeObject(forKey: "followingsCount") as? Int,
      let followersCount = decoder.decodeObject(forKey: "followersCount") as? Int,
      let tweetsCount = decoder.decodeObject(forKey: "tweetsCount") as? Int else { return nil}
    
    self.init(name: name, screen: screen, avatarUrl: avatarUrl, backgroundUrl: backgroundUrl, followingsCount: followingsCount, followersCount: followersCount, tweetsCount: tweetsCount)
  }
}

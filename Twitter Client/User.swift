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
  var id:String
  var screenName:String
  var avatarImageUrl:String
  var backgroundUrl:String?
  var userDescription: String
  var followingsCount:Int
  var followersCount:Int
  var tweetsCount:Int
  
  init(user: JSON) {
    name = user["name"].string!
    screenName = user["screen_name"].string!
    id = user["id_str"].string!
    avatarImageUrl = user["profile_image_url_https"].string!
    backgroundUrl = user["profile_background_image_url_https"].string
    userDescription = user["description"].string!
    followingsCount = user["friends_count"].int!
    followersCount = user["followers_count"].int!
    tweetsCount = user["statuses_count"].int!
  }
  
  private init(name:String, screen:String, id: String, avatarUrl: String, backgroundUrl: String?, description: String, followingsCount: Int, followersCount: Int, tweetsCount: Int){
    self.name = name
    self.screenName = screen
    self.id = id
    self.avatarImageUrl = avatarUrl
    self.backgroundUrl = backgroundUrl
    self.userDescription = description
    self.followingsCount = followingsCount
    self.followersCount = followersCount
    self.tweetsCount = tweetsCount
  }
  
  // MARK: NSCoding
  func encode(with aCoder: NSCoder) {
    aCoder.encode(self.name, forKey: "name")
    aCoder.encode(self.screenName, forKey: "screen")
    aCoder.encode(self.id, forKey: "id")
    aCoder.encode(self.avatarImageUrl, forKey: "avatarUrl")
    aCoder.encode(self.backgroundUrl, forKey: "backgroundUrl")
    aCoder.encode(self.userDescription, forKey: "description")
    aCoder.encode(self.followingsCount, forKey: "followingsCount")
    aCoder.encode(self.followersCount, forKey: "followersCount")
    aCoder.encode(self.tweetsCount, forKey: "tweetsCount")
  }
  
  required convenience init?(coder decoder: NSCoder) {
    let name = decoder.decodeObject(forKey: "name") as! String
    let screen = decoder.decodeObject(forKey: "screen") as! String
    let id = decoder.decodeObject(forKey: "id") as! String
    let avatarUrl = decoder.decodeObject(forKey: "avatarUrl") as! String
    let backgroundUrl = decoder.decodeObject(forKey: "backgroundUrl") as? String
    let description = decoder.decodeObject(forKey: "description") as! String
    let followingsCount = decoder.decodeInteger(forKey: "followingsCount")
    let followersCount = decoder.decodeInteger(forKey: "followersCount")
    let tweetsCount = decoder.decodeInteger(forKey: "tweetsCount")
    
    self.init(name: name, screen: screen, id: id, avatarUrl: avatarUrl, backgroundUrl: backgroundUrl, description: description, followingsCount: followingsCount, followersCount: followersCount, tweetsCount: tweetsCount)
  }
}

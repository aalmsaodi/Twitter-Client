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
    
    var id:Int64 // Text content of tweet
    var user:User
    var tweetText:String
    var creationDate: String
    var tweetAge: String
    
    var favoriteCount:Int?
    var favoritedBtn:Bool?
    var retweetedBtn:Bool
    var retweetCount:Int
    
    init(timeLine: JSON) {
        id = timeLine["id"].int64!
        user = User(user: timeLine["user"])
        tweetText = timeLine["text"].string!
        
        if timeLine["retweeted"].bool! {
            print(tweetText.capturedGroups(withRegex: "RT @(.*):"))
        }
        
        let formatter = DateFormatter()
        // Configure the input format to parse the date string
        formatter.dateFormat = "E M d HH:mm:ss Z y"
        
        let createdAtString = timeLine["created_at"].string!
        let currentTime = Date()
        let createdAt = formatter.date(from: createdAtString)
        let requestedComponent: Set<Calendar.Component> = [.year,.month,.day,.hour,.minute,.second]
        
        let userCalendar = Calendar.current
        let timeDifference = userCalendar.dateComponents(requestedComponent, from: createdAt!, to: currentTime)
        let date = formatter.date(from: createdAtString)!
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        creationDate = formatter.string(from: date)
        if timeDifference.day! > 0 || timeDifference.month! > 0 || timeDifference.year! > 0 {
            formatter.timeStyle = .none
            tweetAge = formatter.string(from: date)
        } else if timeDifference.hour! > 0 {
            tweetAge = "\(timeDifference.hour!)h"
        } else if timeDifference.minute! > 0 {
            tweetAge = "\(timeDifference.minute!)m"
        } else {
            tweetAge = "\(timeDifference.second!)s"
        }
        
        favoriteCount = timeLine["favourites_count"].int
        favoritedBtn = timeLine["favorited"].bool
        retweetCount = timeLine["retweet_count"].int!
        retweetedBtn = timeLine["retweeted"].bool!
    }
}

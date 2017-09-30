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
    var retweetedBy:String?
    
    var favoriteCount:Int?
    var favoritedBtn = false
    var retweetCount:Int
    var retweetedBtn = false
    
    init(timeLine: JSON) {
        id = timeLine["id_str"].string!
        user = User(user: timeLine["user"])
        tweetText = timeLine["text"].string!
        
        if let favCount = timeLine["favourites_count"].int {
            favoriteCount = favCount
        }
        favoritedBtn = timeLine["favorited"].bool!
        retweetCount = timeLine["retweet_count"].int!
        retweetedBtn = timeLine["retweeted"].bool!
        
        if let retweetedByUserName = timeLine["retweeted_status"]["user"]["name"].string {
            retweetedBy = retweetedByUserName
        }
        
        let formatter = DateFormatter()
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
    }
}

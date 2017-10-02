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
    
    init(user: JSON) {
        name = user["name"].string!
        avatarImageUrl = user["profile_image_url_https"].string!
        screenName = "@\(user["screen_name"].string!)"
    }
    
    private init(name:String, screen:String, avatarUrl:String){
        self.name = name
        self.screenName = screen
        self.avatarImageUrl = avatarUrl
    }
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.screenName, forKey: "screen")
        aCoder.encode(self.avatarImageUrl, forKey: "avatarURL")
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let name = decoder.decodeObject(forKey: "name") as? String,
            let screen = decoder.decodeObject(forKey: "screen") as? String,
            let avatarURL = decoder.decodeObject(forKey: "avatarURL") as? String else { return nil}
        
        self.init(name: name, screen: screen, avatarUrl: avatarURL)
    }
}

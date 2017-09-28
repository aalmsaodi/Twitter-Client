//
//  User.swift
//  Twitter Client
//
//  Created by user on 9/26/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import Foundation
import SwiftyJSON

class User {
    
    var name:String
    var screenName:String
    var avatarImageUrl:String
    
    
    init(user: JSON) {
        name = user["name"].string!
        avatarImageUrl = user["profile_image_url_https"].string!
        screenName = "@\(user["screen_name"].string!)"
    }
}

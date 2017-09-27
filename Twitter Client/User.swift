//
//  User.swift
//  Twitter Client
//
//  Created by user on 9/26/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import Foundation

class User {
    
    var name: String
    
    init(dictionary: [String: Any]) {
        name = dictionary["name"] as! String
        
    }
}

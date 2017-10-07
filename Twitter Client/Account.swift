//
//  Account.swift
//  Twitter Client
//
//  Created by user on 10/7/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import BDBOAuth1Manager
import Foundation

class Account: NSObject, NSCoding  {
  var user: User!
  var accessToken: BDBOAuth1Credential?
  
  init(user: User, accessToken: BDBOAuth1Credential?) {
    self.user = user
    self.accessToken = accessToken
  }
  
  private init(user: User, access: BDBOAuth1Credential?) {
    self.user = user
    self.accessToken = access
  }
  
  // MARK: NSCoding
  func encode(with aCoder: NSCoder) {
    aCoder.encode(self.user, forKey: "user")
    aCoder.encode(self.accessToken, forKey: "accessToken")
  }
  
  required convenience init?(coder decoder: NSCoder) {
    let user = decoder.decodeObject(forKey: "user") as! User
    let accessToken = decoder.decodeObject(forKey: "accessToken") as! BDBOAuth1Credential?

    self.init(user: user, access: accessToken)
  }
}

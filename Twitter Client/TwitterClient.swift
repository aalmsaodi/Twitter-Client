//
//  TwitterClient.swift
//  Twitter Client
//
//  Created by user on 9/26/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import Foundation
import Alamofire
import OAuthSwift
import OAuthSwiftAlamofire
import KeychainAccess


class TwitterClient: SessionManager {
    
    static var shared: TwitterClient = TwitterClient()
    
    var oauthManager: OAuth1Swift!
    
    static let consumerKey = "3x5uWdsAUIVb7IvLTiiRl4mrY"
    static let consumerSecret = "Fgu2D5y1Cq3moOSMx1nbJW2SzCDSvINoCoGU38SjwJtn5bXNYt"
    
    static let requestTokenURL = "https://api.twitter.com/oauth/request_token"
    static let authorizeURL = "https://api.twitter.com/oauth/authorize"
    static let accessTokenURL = "https://api.twitter.com/oauth/access_token"
    
    static let callbackURLString = "TwitterClient://"
    
    // Private init for singleton only
    private init() {
        super.init()
        
        // Create an instance of OAuth1Swift with credentials and oauth endpoints
        oauthManager = OAuth1Swift(
            consumerKey: TwitterClient.consumerKey,
            consumerSecret: TwitterClient.consumerSecret,
            requestTokenUrl: TwitterClient.requestTokenURL,
            authorizeUrl: TwitterClient.authorizeURL,
            accessTokenUrl: TwitterClient.accessTokenURL
        )
        
        // Retrieve access token from keychain if it exists
        if let credential = retrieveCredentials() {
            oauthManager.client.credential.oauthToken = credential.oauthToken
            oauthManager.client.credential.oauthTokenSecret = credential.oauthTokenSecret
        }
        
        // Assign oauth request adapter to Alamofire SessionManager adapter to sign requests
        adapter = oauthManager.requestAdapter
    }
    
    // MARK: Handle url
    // Finish oauth process by fetching access token
    func handle(url: URL) {
        OAuth1Swift.handle(url: url)
    }
    
    // MARK: Save Tokens in Keychain
    private func save(credential: OAuthSwiftCredential) {
        
        // Store access token in keychain
        let keychain = Keychain()
        let data = NSKeyedArchiver.archivedData(withRootObject: credential)
        keychain[data: "twitter_credentials"] = data
    }
    
    // MARK: Retrieve Credentials
    private func retrieveCredentials() -> OAuthSwiftCredential? {
        let keychain = Keychain()
        
        if let data = keychain[data: "twitter_credentials"] {
            let credential = NSKeyedUnarchiver.unarchiveObject(with: data) as! OAuthSwiftCredential
            return credential
        } else {
            return nil
        }
    }
    
    // MARK: Clear tokens in Keychain
    private func clearCredentials() {
        // Store access token in keychain
        let keychain = Keychain()
        do {
            try keychain.remove("twitter_credentials")
        } catch let error {
            print("error: \(error)")
        }
    }
    
    func login(success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
     
        let callbackURL = URL(string: TwitterClient.callbackURLString)!
        oauthManager.authorize(withCallbackURL: callbackURL, success: { (credential, _response, parameters) in
            
            self.save(credential: credential)
            
            self.getCurrentAccount(completion: { (user, error) in
                if let error = error {
                    failure(error)
                } else if let user = user {
                    print("Welcome \(user.name)")
                    
                    // MARK: TODO: set User.current, so that it's persisted
                    
                    success()
                }
            })
        }) { (error) in
            failure(error)
        }
    }
    
    func logout() {
        clearCredentials()
        
        // TODO: Clear current user by setting it to nil
//        NotificationCenter.default.post(name: NSNotification.Name("didLogout"), object: nil)
    }

    func getCurrentAccount(completion: @escaping (User?, Error?) -> ()) {
        request(URL(string: "https://api.twitter.com/1.1/account/verify_credentials.json")!)
            .validate()
            .responseJSON { response in
                switch response.result {
                    case .failure(let error):
                        completion(nil, error)

                    case .success:
                        guard let userDictionary = response.result.value as? [String: Any] else {
                            completion(nil, "Unable to create user dictionary" as? Error)
                            return
                        }
                        completion(User(dictionary: userDictionary), nil)
                }
        }
    }
    
}

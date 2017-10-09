//
//  ViewController.swift
//  Twitter Client
//
//  Created by user on 10/8/17.
//  Copyright © 2017 YSH. All rights reserved.
//

import UIKit

class TakingNewPhotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  
  @IBOutlet weak private var profilePic: UIImageView!
  fileprivate let imagePicker = UIImagePickerController()
  
  var avatarUrl: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imagePicker.delegate = self
    
    if let url = URL(string: avatarUrl) {
      profilePic.setImageWith(url)
    }
  }
  
  @IBAction private func onLibraryBtn(_ sender: Any) {
    imagePicker.sourceType = .photoLibrary
    self.present(self.imagePicker, animated: true, completion: nil)
  }
  
  @IBAction private func onPhotoBtn(_ sender: Any) {
    imagePicker.sourceType = .camera
    self.present(self.imagePicker, animated: true, completion: nil)
  }
  
  @IBAction private func onCancelBtn(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      let smallSizeImage = pickedImage.resized(withPercentage: 0.1)
      let imageData:NSData = UIImagePNGRepresentation(smallSizeImage!)! as NSData
      let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
      TwitterClient.shared?.updateProfileImage(image: strBase64)
      imagePicker.dismiss(animated: true, completion: nil)
      self.dismiss(animated: false, completion: nil)
    }
  }
}

//
//  ViewController.swift
//  Selfie Arm
//
//  Created by Nick Giancola on 3/19/16.
//  Copyright © 2016 Nick Giancola. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  @IBOutlet weak var takePhotoButton: UIButton!
  @IBOutlet weak var renderedImageView: UIImageView!
  @IBOutlet weak var shareButton: UIButton!
  
  let imagePicker = UIImagePickerController()
  var renderedImage: UIImage?
  
  let overlays = ["overlay", "thumb", "face"]

  override func viewDidLoad() {
    super.viewDidLoad()
    imagePicker.delegate = self
    
    if !cameraIsAvailable() { takePhotoButton.hidden = true }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func onSelectPhotoPressed(sender: AnyObject) {
    imagePicker.sourceType = .PhotoLibrary
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  @IBAction func onTakePhotoPressed(sender: AnyObject) {
    guard cameraIsAvailable() else { return }
    
    imagePicker.sourceType = .Camera
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
  @IBAction func onSharePressed(sender: AnyObject) {
    if let image = renderedImage { share(image) }
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage, image = renderImageWithOverlay(pickedImage) {
      self.renderedImage = image
      showImage(image)
    }
    
    dismissViewControllerAnimated(true, completion: nil)
  }

  func renderImageWithOverlay(image: UIImage) -> UIImage? {
    let rect = CGRect(x: 0, y: 0, width: 800, height: 800)
    
    let userImage = UIImageView(image: image)
    userImage.frame = rect
    userImage.contentMode = .ScaleAspectFill
    
    let overlayImage = UIImageView(image: randomOverlay())
    overlayImage.frame = rect
    overlayImage.contentMode = .ScaleToFill
    
    UIGraphicsBeginImageContext(rect.size)
    
    if let context = UIGraphicsGetCurrentContext() {
      userImage.layer.renderInContext(context)
      overlayImage.layer.renderInContext(context)
      
      return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    UIGraphicsEndImageContext()
    
    return nil
  }
  
  func showImage(image: UIImage) {
    renderedImageView.image = image
    renderedImageView.hidden = false
    shareButton.hidden = false
  }
  
  func randomOverlay() -> UIImage {
    let randomOverlayIndex = Int(arc4random_uniform(UInt32(overlays.count)))
    let overlayName = overlays[randomOverlayIndex]
    return UIImage(named: overlayName)!
  }
  
  func cameraIsAvailable() -> Bool {
    return UIImagePickerController.isSourceTypeAvailable(.Camera)
  }
  
  func share(image: UIImage) {
    let shareVC = UIActivityViewController(activityItems: [(image)], applicationActivities: nil)
    
    shareVC.completionWithItemsHandler = { activityType, completed, items, error in
      if completed {
        let alert = UIAlertController(title: "Sweet!", message: "You just made an awesome selfie. Go ahead and make some more!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK!", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
      }
    }
    
    self.presentViewController(shareVC, animated: true, completion: nil)
  }
}

